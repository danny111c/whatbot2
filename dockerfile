FROM python:3.11-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y wget unzip gnupg curl

# Instalar Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y google-chrome-stable

# (Opcional) Verificar versión de Chrome para saber qué ChromeDriver usar
# RUN google-chrome --version

# Descargar y configurar ChromeDriver (actualiza la versión según la instalada de Chrome)
RUN CHROMEDRIVER_VERSION=116.0.5845.96 && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver

# Agregar /usr/local/bin al PATH
ENV PATH="/usr/local/bin:${PATH}"

# Directorio de trabajo
WORKDIR /app

# Copiar el código de la aplicación
COPY . /app

# Instalar dependencias de Python
RUN pip install --upgrade pip && pip install -r requirements.txt

# Comando para iniciar la aplicación
CMD ["python", "bot.py"]
