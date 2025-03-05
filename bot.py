import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build

# -------------------------
# CONFIGURACIÓN DE WHATSAPP
# -------------------------
def iniciar_whatsapp():
    # Configurar Chrome en modo headless para Render
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Sin interfaz gráfica
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--user-data-dir=/opt/render/project/src/.user_data")  # Persistencia de sesión

    # Ruta de ChromeDriver en Render
    service = Service(executable_path="/opt/render/project/src/chromedriver")
    
    # Inicializar el navegador
    driver = webdriver.Chrome(service=service, options=chrome_options)
    driver.get("https://web.whatsapp.com")
    return driver

# -------------------------
# LEER DATOS DE GOOGLE SHEET
# -------------------------
def leer_google_sheet():
    # Credenciales desde variable de entorno
    creds_json = os.getenv("GOOGLE_CREDENTIALS_JSON")
    creds = Credentials.from_service_account_info(eval(creds_json))
    service = build("sheets", "v4", credentials=creds)

    # Leer datos (A2:B100)
    sheet = service.spreadsheets()
    result = sheet.values().get(
        spreadsheetId=os.getenv("SPREADSHEET_ID"),
        range="A2:B100"
    ).execute()
    return result.get("values", [])

# -------------------------
# ENVIAR MENSAJES
# -------------------------
def enviar_mensajes(driver, telefono, mensaje):
    try:
        # Abrir chat de WhatsApp Web
        driver.get(f"https://web.whatsapp.com/send?phone={telefono}&text={mensaje}")
        time.sleep(10)  # Esperar a que cargue

        # Hacer clic en "Enviar"
        send_button = driver.find_element(By.XPATH, '//button[@data-testid="send"]')
        send_button.click()
        time.sleep(5)  # Esperar confirmación
        print(f"✅ Mensaje enviado a {telefono}")
    except Exception as e:
        print(f"❌ Error al enviar a {telefono}: {e}")

# -------------------------
# FLUJO PRINCIPAL
# -------------------------
if __name__ == "__main__":
    # Iniciar WhatsApp Web (escanear QR la primera vez)
    driver = iniciar_whatsapp()

    # Capturar QR (solo la primera vez)
    try:
        qr_element = driver.find_element(By.XPATH, '//div[@data-ref]')
        qr_element.screenshot("/opt/render/project/src/qr.png")
        print("QR guardado en /opt/render/project/src/qr.png")
    except:
        print("No se encontró QR. Sesión activa.")

    # Leer datos de Google Sheet
    datos = leer_google_sheet()
    for fila in datos:
        telefono, mensaje = fila[0], fila[1]
        enviar_mensajes(driver, telefono, mensaje)
        time.sleep(random.randint(15, 30))  # Intervalo aleatorio

    driver.quit()