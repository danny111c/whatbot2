FROM python:3.11-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y wget unzip gnupg curl

# Descargar Google Chrome 76.0.3809.132 (versión 76)
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/google-chrome.deb && \
    dpkg -i /tmp/google-chrome.deb || apt-get install -y -f && \
    rm /tmp/google-chrome.deb

# Verificar que Google Chrome 76 se instaló correctamente
RUN google-chrome --version

# Descargar ChromeDriver 76.0.3809.68 (compatible con Chrome 76)
RUN wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/76.0.3809.68/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip -d /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm /tmp/chromedriver.zip

# Verificar que ChromeDriver 76 se instaló correctamente
RUN chromedriver --version

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
