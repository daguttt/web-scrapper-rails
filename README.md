# Web Scraper Rails

App that allows users to scrape a web page and get a list of all of the links in that page.

## Tech Stack 

- Rails 7.2.2
- PostgreSQL

## Local Dev Setup

### 1. Environment variables

Copy the [`.env.erb`](./.env.erb) content and create the `.env` file in the root of the project folder structure

```bash
cp .env.erb .env
```

> [!NOTE]
> Make sure you modify the `<password>` placeholder in `DATABASE_PASSWORD` with your own database password.
   

### 2. Set up `master.key`
Use the following command to create the `master.key` file with the default secret key given by `rails new`:

```bash
echo "49781a401c3063bb7858fd0b4e4aba13" > config/master.key
```

> [!NOTE]
> This is done for the sake of simplicity. In a production environment, you should ask the team for the `master.key`.

### 3. Database

1. Create the database

```bash
rails db:create
```

2. Migrate the database

```bash
rails db:migrate
```



