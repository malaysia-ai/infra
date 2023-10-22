# PostgreSQL

## Install and Create database

### 1. Install postgress.
https://ubuntu.com/server/docs/databases-postgresql

`sudo apt install postgres `

## Configure PostgreSQL connection

### 1. Configure conf file. This allows PostgreSQL to listen on all available IP addresses.
https://blog.devart.com/configure-postgresql-to-allow-remote-connection.html

`sudo nano /etc/postgresql/12/main/postgresql.conf` :

change from

```
#listen_addresses = 'localhost'
```

to

```
listen_addresses = '*'
```


`sudo nano /etc/postgresql/12/main/pg_hba.conf` :

change from 

```
# IPv4 local connections: 

host    all             all             127.0.0.1/32            md5
```

to

```
# IPv4 local connections:

host    all             all             0.0.0.0/0            md5
```

### 2. Create a database in PostgreSQL

`createdb malaysiaai-0`

create a new connection to the PostgreSQL server and connect to the database named malaysiaai-0

`psql -d malaysiaai-0`

### 3. Restart postgres service

`sudo service postgresql restart`

## Connect database through ssh tunnel

### 1. SSH Tunnel inputs

```
Host : Server ip
Port : 22
Username : Server user
Authentication : Public Key
Private Key : .pem or .ppk
Passphrase: Password set during the public key generation.
```

# MySQL

## Coming soon
