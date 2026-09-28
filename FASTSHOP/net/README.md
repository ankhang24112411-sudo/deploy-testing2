# spring-thymeleaf-fastshop
This is an e-commerce sales page. We desgined it with 4 technology include
* AngularJs
* Thymeleaf framework
* Spring boot framework
* Java core

Website just concenstrate 3 main roles in role hirarchies is: Admin, Staff and User

1. Admin is highest role. It can see and look up all of accounts and watch report, statistical follow a month
2. Staff is role which can see orders everyday. They can write some reports and send it or manager list products or categories of Fastshop
3. User is role which depend customers. Customers can buy and pay products follow their bill

## Docker deploy

1. Review `.env` before deploying. The file is already created for local Docker, but change at least `DB_PASSWORD` on a real server.

Important values:

- `APP_PORT`: host port for the web app.
- `DB_PORT`: host port for SQL Server.
- `DB_NAME`: database name created on first start.
- `DB_USERNAME` / `DB_PASSWORD`: SQL Server login used by the app.
- `MAIL_USERNAME` / `MAIL_PASSWORD`: optional Gmail account and app password.
- `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`: optional Google OAuth values.
- `FACEBOOK_CLIENT_ID` / `FACEBOOK_CLIENT_SECRET`: optional Facebook OAuth values.

Do not commit `.env`; it is ignored by git and Docker.

2. Build and start:

```bash
docker compose up -d --build
```

The app is exposed at `http://localhost:8000` by default. Change `APP_PORT` in `.env` if the host port is already used.

3. Check logs:

```bash
docker compose logs -f web
```

4. Stop services:

```bash
docker compose down
```

To delete the SQL Server data volume as well:

```bash
docker compose down -v
```
