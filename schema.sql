-- Postflow / Omar Contadores — banco compartilhado da equipe
create extension if not exists pgcrypto;

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  platform text not null default 'Instagram',
  format text not null default 'Feed',
  date date,
  time text,
  status text not null default 'Ideia',
  owner text not null default '',
  caption text not null default '',
  link text not null default '',
  notes text not null default '',
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.posts enable row level security;

-- Todos os usuários autenticados e autorizados no projeto compartilham o calendário.
drop policy if exists "Equipe pode visualizar postagens" on public.posts;
create policy "Equipe pode visualizar postagens" on public.posts
for select to authenticated using (true);

drop policy if exists "Equipe pode criar postagens" on public.posts;
create policy "Equipe pode criar postagens" on public.posts
for insert to authenticated with check (auth.uid() = created_by);

drop policy if exists "Equipe pode editar postagens" on public.posts;
create policy "Equipe pode editar postagens" on public.posts
for update to authenticated using (true) with check (true);

drop policy if exists "Equipe pode excluir postagens" on public.posts;
create policy "Equipe pode excluir postagens" on public.posts
for delete to authenticated using (true);

-- Habilita eventos em tempo real para a tabela.
alter table public.posts replica identity full;
do $$ begin
  alter publication supabase_realtime add table public.posts;
exception when duplicate_object then null;
end $$;
