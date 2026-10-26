from flask import Flask, render_template, request
import sqlite3

app = Flask(__name__)

def initdb():
    c = sqlite3.connect("users.db")
    cur = c.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS users (username TEXT, password TEXT)")
    cur.execute("INSERT OR IGNORE INTO users VALUES ('admin', 'supersecret')")
    c.commit()
    c.close()

@app.route("/", methods=["GET", "POST"])
def index():
    m = None
    s = None
    if request.method == "POST":
        u = request.form.get("username", "")
        p = request.form.get("password", "")
        c = sqlite3.connect("users.db")
        cur = c.cursor()
        cur.execute("SELECT * FROM users WHERE username = ? AND password = ?", (u, p))
        x = cur.fetchone()
        c.close()
        if x:
            m = "Login Berhasil! Selamat datang."
            s = "success"
        else:
            m = "Login Gagal! Kredensial tidak valid."
            s = "danger"
    return render_template("index.html", message=m, status_class=s)

if __name__ == "__main__":
    initdb()
    app.run(host="0.0.0.0", port=5000)  # nosemgrep
