FROM python:3.11-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y wget unzip gnupg curl

# Instalar Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

# Descargar y configurar ChromeDriver (asegúrate de que la versión sea compatible con la versión de Chrome instalada)
RUN CHROMEDRIVER_VERSION=114.0.5735.90 && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el código de la aplicación
COPY . /app

# Instalar dependencias de Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Comando para iniciar la aplicación
CMD ["python", "bot.py"]
