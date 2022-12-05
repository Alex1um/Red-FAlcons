# Docks for backend

## OpenAPI specification
OpenAPI specification stored in openapi.json.

## Requirements

1. python 3.10
2. PostgreSQL

## App start
To start app you need to:

1. Change current directory to 'back': `cd back`

2. Set up venv: `python -m venv venv`

3. Activate venv: `source venv/bin/activate`

4. Install dependencies in your venv: `pip install -r requirementx.txt`

5. Set up environment variables (or use `.env` file) with variables:
```
secret = <your secret string to hash JWT>
algorithm = HS256
postgres_host = <your postgres host>
postgres_port = <your postgres port>
postgres_user = <your postgres user>
postgres_password = <your postgres password>
postgres_database_name = <your postgres database name>
```

6. Run app: `python main.py`

## API endpoints

### `POST /auth/register`:
"Regiser new user"

Body: 
```
    {
        username: str,
        password: str
    }
```

Response:
```
    {
        id: int,
        username: str,
        created_at: datetime
    }
```

### `POST /auth/login`:
"Log in"

Body(form-data): 
```
    username: str
    password: str
```

Response:
```
    {
        access_token: str,
        token_type: str
    }
```

### `GET /cards/`:
"Get all user's cards"

Headers:
```
Authorization: <token_type> <access_token>
```

Response:
```
    [
        {   
            store_id: int,
            code: int,
            id: int,
            created_at: datetime
        }
    ]
```

### `GET /cards/geo?latitude=<latitude>&longitude=<longitude>`:
"Get user's cards sorted by geolocation"

Headers:
```
Authorization: <token_type> <access_token>
```

Response:
```
    [
        {   
            store_id: int,
            code: int,
            id: int,
            created_at: datetime
        }
    ]
```

### `POST /cards/`:
"Add new user's card"

Headers:
```
Authorization: <token_type> <access_token>
```

Body:
```
    {
        store_id: int,
        code: int
    }
```

Response:
```
    {   
        store_id: int,
        code: int,
        id: int,
        created_at: datetime
    }
```

### `GET /stores`:
"Get all available stores."

Headers:
```
Authorization: <token_type> <access_token>
```

Response:
```
    [
        {   
            id: int,
            name: str
        }
    ]
```

## Manual QA

Test cases: 10
Successful: 10
Failed: 0
Seccess rate: 100%
Fail rate: 0%
Time: n/a
