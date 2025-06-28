from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
import psycopg2

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

conn = psycopg2.connect(
    dbname="crypto_exchange",
    user="postgres",
    password="1",
    host="localhost",
    port="5433"
)

@app.get("/cryptocurrencies")
def get_cryptocurrencies():
    with conn.cursor() as cur:
        cur.execute("SELECT id_currency, currency_name, currency_price_usd FROM cryptocurrency")
        rows = cur.fetchall()
        return [{"id": r[0], "name": r[1], "price": r[2]} for r in rows]

@app.post("/check_user")
async def check_user(request: Request):
    data = await request.json()
    name = data.get("name")
    with conn.cursor() as cur:
        cur.execute("SELECT id FROM users WHERE name = %s", (name,))
        user = cur.fetchone()
        return {"exists": bool(user)}

@app.post("/register_user")
async def register_user(request: Request):
    data = await request.json()
    name = data.get("name")
    email = data.get("email")
    password = data.get("password")

    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO users (name, email, password) VALUES (%s, %s, %s) RETURNING id",
            (name, email, password)
        )
        user_id = cur.fetchone()[0]
        conn.commit()
        return {"id": user_id, "name": name}

@app.post("/authorize_user")
async def authorize_user(request: Request):
    data = await request.json()
    email = data.get("email")
    password = data.get("password")
    with conn.cursor() as cur:
        cur.execute("SELECT id, name FROM users WHERE email = %s AND password = %s", (email, password))
        user = cur.fetchone()
        if user:
            return {"authorized": True, "id": user[0], "name": user[1]}
        else:
            return {"authorized": False}

@app.get("/staking/{user_id}")
def get_staking(user_id: int):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT s.id_staking, s.staking_sum, s.staking_percentage, s.staking_start_date, s.staking_end_date
            FROM staking s
            JOIN spot_wallet w ON s.id_wallet = w.id_wallet
            WHERE w.id_user = %s
        """, (user_id,))
        rows = cur.fetchall()
        return [
            {
                "id": r[0],
                "sum": r[1],
                "percent": r[2],
                "start": r[3],
                "end": r[4]
            }
            for r in rows
        ]

@app.post("/add_wallet")
async def add_wallet(request: Request):
    data = await request.json()
    currency = data["currency"]
    balance = data["balance"]
    user_id = data["user_id"]

    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO spot_wallet (currency, balance, id_user) VALUES (%s, %s, %s)",
            (currency, balance, user_id)
        )
        conn.commit()
        return {"status": "success"}

@app.get("/wallets/{user_id}")
def get_wallets(user_id: int):
    with conn.cursor() as cur:
        cur.execute("""
            SELECT id_wallet, currency, balance 
            FROM spot_wallet 
            WHERE id_user = %s
        """, (user_id,))
        rows = cur.fetchall()
        return [
            {
                "id_wallet": r[0],
                "currency": r[1],
                "balance": r[2]
            }
            for r in rows
            ]

@app.delete("/delete_wallet/{wallet_id}")
def delete_wallet(wallet_id: int):
    with conn.cursor() as cur:
        cur.execute("SELECT balance FROM spot_wallet WHERE id_wallet = %s", (wallet_id,))
        result = cur.fetchone()
        if result is None:
            return {"status": "error", "reason": "Wallet not found"}
        if result[0] != 0.0:
            return {"status": "error", "reason": "Balance must be zero"}

        cur.execute("DELETE FROM spot_wallet WHERE id_wallet = %s", (wallet_id,))
        conn.commit()
        return {"status": "deleted"}

#для создания нового стейкинга
@app.post("/add_staking")
async def add_staking(request: Request):
    data = await request.json()
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO staking (id_wallet, staking_start_date, staking_end_date, staking_sum, staking_percentage)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            data["id_wallet"],
            data["staking_start_date"],
            data["staking_end_date"],
            data["staking_sum"],
            data["staking_percentage"]
        ))
        conn.commit()
        return {"status": "success"}

#для ордеров и транзакций

from datetime import date

@app.post("/create_order")
async def create_order(request: Request):
    data = await request.json()
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO orders (
                id_users, id_currency, order_count_currency,
                order_type, order_status
            )
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id_order
        """, (
            data["id_users"],
            data["id_currency"],
            data["order_count_currency"],
            data["order_type"],
            data["order_status"]
        ))
        order_id = cur.fetchone()[0]
        conn.commit()
        return {"id_order": order_id}

@app.post("/create_transaction")
async def create_transaction(request: Request):
    data = await request.json()
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO transactions (
                id_wallet, id_order, id_currency,
                trans_data, trans_status
            )
            VALUES (%s, %s, %s, %s, %s)
        """, (
            data["id_wallet"],
            data["id_order"],
            data["id_currency"],
            date.today(),
            data["trans_status"]
        ))
        conn.commit()
        return {"status": "success"}

# @app.post("/account_oper")
# async def create_account_oper(request: Request):
#     data = await request.json()
#     with conn.cursor() as cur:
#         cur.execute("""
#             INSERT INTO account_oper (
#                 id_wallet,
#                 account_oper_sum,
#                 account_oper_currency,
#                 account_oper_status,
#                 account_oper_type
#             )
#             VALUES (%s, %s, %s, %s, %s)
#         """, (
#             data["id_wallet"],
#             data["account_oper_sum"],
#             data["account_oper_currency"],
#             True,  # Предполагаем, что транзакция всегда успешна (имитация)
#             data["account_oper_type"]
#         ))
#         conn.commit()
#         return {"status": "success"}

@app.post("/account_oper")
async def create_account_oper(request: Request):
    data = await request.json()
    id_wallet = data["id_wallet"]
    amount = data["account_oper_sum"]
    currency = data["account_oper_currency"]
    is_deposit = data["account_oper_type"]

    with conn.cursor() as cur:
        # Добавление записи операции
        cur.execute("""
            INSERT INTO account_oper (
                id_wallet,
                account_oper_sum,
                account_oper_currency,
                account_oper_status,
                account_oper_type
            )
            VALUES (%s, %s, %s, %s, %s)
        """, (
            id_wallet,
            amount,
            currency,
            True,  # транзакция успешна
            is_deposit
        ))

        # Обновление баланса кошелька
        if is_deposit:
            cur.execute("UPDATE spot_wallet SET balance = balance + %s WHERE id_wallet = %s", (amount, id_wallet))
        else:
            cur.execute("UPDATE spot_wallet SET balance = balance - %s WHERE id_wallet = %s", (amount, id_wallet))

        conn.commit()
        return {"status": "success"}