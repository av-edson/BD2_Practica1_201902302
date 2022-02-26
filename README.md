# BD2_Practica1_201902302
Practica 1 Laboratorio Sistemas de Bases de Datos



### comandos
    
    docker run -e "ACCEPT_EULA=Y" -e 'SA_PASSWORD=yourStrong(!)Password' -p 1433:1433 -d mcr.microsoft.com/mssql/server:2019-latest

    docker run {idContainer}

    docker exec -it e69e056c702d "bash"

### Copiar el archivo al contenedor

    docker exec -it {idContainer} mkdir /var/opt/mssql/backup

    cd 'Documents/Vainas U/bases2/ScriptsVersionsBD'

    docker cp BD2_2019Enterprise.sql ef8979fde7a8:/var/opt/mssql/backup
### Luego de entrar esto

    /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'yourStrong(!)Password' -i /var/opt/mssql/backup/BD2_2019Enterprise.sql 


