# Adicionando mais repositórios e atualizando o sistema

### 💾 Baixando keyrings

**Microsoft:**
```bash
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
```

**Google:**
```bash
curl -sSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google.gpg
```

**DBeaver:**
```bash
curl -sSL https://dbeaver.io/debs/dbeaver.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/dbeaver.gpg
```

**Docker (se for ambiente Linux):**
```bash
curl -sSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### ➕ Adicionando repositorios

**Microsoft:**
```bash
echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge.list > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/microsoft-code.list > /dev/null
```

**Microsoft Antigo (um repo para cada release do Ubuntu):**
```bash
echo "deb [signed-by=/etc/apt/keyrings/microsoft.gpg arch=amd64] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") main" | sudo tee /etc/apt/sources.list.d/microsoft-ubuntu.list > /dev/null
```

**Google:**
```bash
echo "deb [signed-by=/etc/apt/keyrings/google.gpg arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
```

**DBeaver:**
```bash
echo "deb [signed-by=/etc/apt/keyrings/dbeaver.gpg arch=amd64] https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list > /dev/null
```

**Docker (um repo para cada release do Ububtu):**
```bash
echo "deb [signed-by=/etc/apt/keyrings/docker.gpg arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 🔄 Atualizando o sistema

**Atualize a lista de pacotes:**
```bash
sudo apt update
```

**Atualize os pacotes já instalados:**
```bash
sudo apt upgrade -y
```

