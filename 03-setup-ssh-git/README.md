# Configuração de chaves SSH e Git

## Chaves SSH 

Gerar chave pessoal:
```bash
ssh-keygen -t rsa -C "henricos@gmail" -f ~/.ssh/id_rsa_henricos -N ""
```

Gerar chave profissional:
```bash
ssh-keygen -t rsa -C "henrico.scaranello@techne.com.br" -f ~/.ssh/id_rsa_henrico_scaranello -N ""
```

## Cadastrar a chave pessoal no GitHub pessoal

Acessar https://github.com com a conta henricos
Icone de Usuário > Settings > SSH and GPG Keys > New SSH Key
Colar conteúdo do arquivo id_rsa_henricos.pub

## Cadastrar a chave profissional no GitHub profissional

Acessar  https://github.com com a conta henrico-scaranello
Icone de Usuário > Settings > SSH and GPG Keys > New SSH Key
Colar conteúdo do arquivo id_rsa_henrico_scaranello.pub

## Cadastrar a chave profissional no Azure DevOps

Acessar https://dev.azure.com/technecloud com a conta da Techne
Icone de Users Setting > SSH public keys > New Key
Colar conteúdo do arquivo id_rsa_henrico_scaranello.pub

## Mapear cada chave ssh ao respectivo serviço git

1. Baixe o arquivo config da pasta files
2. Copie ele na pasta ~/.ssh

Esse arquivo define "Hosts" mapeando cada chave a um respectivo HostName

Ao clonar um respositório, basta trocar HostName que fica depois do @ (ex: github.com) pelo "Host" definido no arquivo config (ex: github-henricos)

Exemplo:
- **Antes:** `git clone git@github.com:henricos/setup-workstation.git`
- **Depois:** `git clone git@github-henricos:henricos/setup-workstation.git`

-------------------------------------------

## Git e repositorios

### Instalar o Git

Você pode verificar a versão instalada com o comando:
```bash
git --version
```

Caso não esteja instalado, basta executar o comando:
```bash
sudo apt install -y git
```

### Criar as pastas de repositorio

Pastas de repositórios pessoais:
```bash
mkdir -p ~/github/henricos
mkdir -p /mnt/c/Users/henrico/github/henricos
```

Pastas de repositórios profissionais:
```bash
mkdir -p ~/github/techne
mkdir -p ~/azuregit
```

### Configuração basica do Git

1. Baixar os arquivos .gitconfig* da pasta files
2. Copiar na pasta home

Eles irao configurar user.name, pull.rebase e user.email dinâmico baseado no caminho do repositório 

### Configuração de difftool

Se quiser usar o o WinMerge (do Windows abrindo arquivos no WSL):
```bash
git config --global difftool.prompt false
git config --global diff.tool winmerge
git config --global difftool.winmerge.cmd '"/mnt/c/Program Files (x86)/WinMerge/WinMergeU.exe" -e -u "`wslpath -w $LOCAL`" "`wslpath -w $REMOTE`"'
git config --global merge.tool winmerge
git config --global mergetool.winmerge.cmd '"/mnt/c/Program Files (x86)/WinMerge/WinMergeU.exe" -e -u -fm -wl -wr "`wslpath -w $LOCAL`" "`wslpath -w $MERGED`" "`wslpath -w $REMOTE`"'
```

Se quiser usar o Meld (Linux):
```bash
git config --global difftool.prompt false
git config --global diff.tool meld
git config --global difftool.meld.cmd 'meld "$LOCAL" "$REMOTE"'
git config --global merge.tool meld
git config --global mergetool.meld.cmd 'meld "$LOCAL" "$MERGED" "$REMOTE" --output "$MERGED"'
```
