# Supabase Realtime Chat

- Every text message is public and can be seen by anyone
- Create or join your chat room (if a chat room doesn't exist with a particular Chat ID, it will be created)
- Anyone can join any chat room by providing the Chat ID
- Texts older than 5 minutes are deleted from the database
- Do not share any private info over the chat rooms
- Makes use of Supabase's Realtime feature

## Run this app locally

### Prerequisites

Set up the .env file with your Supabase credentials

```bash
cp .env.example .env
```

### Run the app

```bash
git clone git@github.com:danger-ahead/flutter_supabase_realtime_chat_app.git && /
cd flutter_supabase_realtime_chat_app && /
flutter pub get && /
flutter run
```

## Supabase queries for setting up the environment

```sql
-- create supabase table 'chats'
create table
  public.chats (
    id uuid not null default gen_random_uuid (),
    username text not null,
    chat text not null,
    created_at timestamp with time zone not null default now(),
    chat_id text not null,
    constraint chats_pkey primary key (id)
  ) tablespace pg_default;
```

```sql
-- trigger function for deleting texts older than 5 minutes
-- fired for each new insertion on chats table
CREATE OR REPLACE FUNCTION delete_old_records()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM chats
  WHERE created_at < NOW() - INTERVAL '5 minutes';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_delete_old_records
AFTER INSERT ON chats
FOR EACH ROW
EXECUTE FUNCTION delete_old_records();
```
