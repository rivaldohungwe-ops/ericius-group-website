-- =========================================================
-- Ericius Group — Migration 2
-- Run this in Supabase: SQL Editor > New query > paste > Run
-- Safe to run on your existing database — only adds new things.
-- =========================================================

-- Links a salary row to the financial_entries expense it auto-created,
-- so marking someone Paid/Half Paid/Pending keeps the books in sync
-- without creating duplicate expense entries.
alter table public.salaries
  add column if not exists expense_entry_id bigint references public.financial_entries(id);

-- Lets an employee/driver see their own salary rows (their own pay
-- history) without seeing anyone else's — admins already see everything.
do $$
begin
  if not exists (
    select 1 from pg_policies
    where schemaname = 'public' and tablename = 'salaries' and policyname = 'Employees view own salary'
  ) then
    execute 'create policy "Employees view own salary" on public.salaries for select using (auth.uid() = employee_id)';
  end if;
end $$;
