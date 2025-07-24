# Configurar shell

## Aliases

1. Edite o arquivo específico de aliases

**Versão bash**
```bash
echo "


##################################################

# chavear versao de java
alias usar-java-11=\"sudo update-java-alternatives -s java-1.11.0-openjdk-amd64 -v\"
alias usar-java-17=\"sudo update-java-alternatives -s java-1.17.0-openjdk-amd64 -v\"
" > ~/.bash_aliases
```



## Resources

1. Baixe os arquivos .env* da pasta files
2. Copie na pasta home
3. Edite o arquivo específico de resources

**Versão bash**
```bash
echo "


##################################################

# prompt colorido mostrando branch do git
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
export PS1='\[\033[01;32m\][\w] \[\e[91m\]\$(parse_git_branch)\[\e[00m\] -> '

# carrega arquivo de variaveis de ambiente
source ~/.env_techne
source ~/.env_pessoal

" >> ~/.bashrc
```
