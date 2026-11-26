-- Synthetic laboratory: private server-side contract, not an authentication endpoint.
create table gesta_bank.diary_revision_demo(
 id uuid primary key default gen_random_uuid(),
 diary_id uuid not null references gesta_bank.diary_demo(id),
 revision bigint not null check(revision>0),
 request_id uuid not null unique,
 previous_value jsonb,
 new_value jsonb not null,
 recorded_at timestamptz not null default now(),
 unique(diary_id,revision)
);
alter table gesta_bank.diary_revision_demo enable row level security;
revoke all on gesta_bank.diary_revision_demo from public,anon,authenticated;
alter table gesta_bank.diary_demo add column revision bigint not null default 0 check(revision>=0);
create function gesta_bank.save_diary_demo(p_profile uuid,p_pregnancy uuid,p_date date,p_revision bigint,p_request uuid,p_weight numeric,p_mood text,p_water integer,p_headache boolean)
returns text language plpgsql security invoker set search_path='' as $$
declare d gesta_bank.diary_demo%rowtype; a gesta_bank.diary_revision_demo%rowtype; v jsonb; old_v jsonb; next_rev bigint;
begin
 if p_profile is null or p_pregnancy is null or p_date is null or p_revision is null or p_revision<0 or p_request is null or p_date not between date '2026-01-01' and date '2027-12-31' or (p_weight is not null and p_weight not between 30 and 250) or (p_mood is not null and p_mood not in ('Tranquila','Con energía','Cansada','Emocionada')) or (p_water is not null and p_water not between 0 and 30) or (p_weight is null and p_mood is null and p_water is null and p_headache is null) then return 'INVALID';end if;
 perform 1 from gesta_bank.pregnancy_demo where id=p_pregnancy and profile_id=p_profile for update;
 if not found then return 'DENIED';end if;
 perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request::text,0));
 v:=pg_catalog.jsonb_build_object('pregnancy_id',p_pregnancy,'observed_on',p_date,'weight_kg',p_weight,'mood',p_mood,'water_glasses',p_water,'headache',p_headache,'expected_revision',p_revision);
 select * into a from gesta_bank.diary_revision_demo where request_id=p_request;
 if found then if a.new_value=v then return 'REPLAY';else return 'REQUEST_CONFLICT';end if;end if;
 select * into d from gesta_bank.diary_demo where pregnancy_id=p_pregnancy and observed_on=p_date for update;
 if found then
  if d.revision<>p_revision then return 'CONFLICT';end if;
  old_v:=pg_catalog.to_jsonb(d);next_rev:=d.revision+1;
  update gesta_bank.diary_demo set weight_kg=p_weight,mood=p_mood,water_glasses=p_water,headache=p_headache,revision=next_rev where id=d.id;
 else
  if p_revision<>0 then return 'CONFLICT';end if;
  next_rev:=1;
  insert into gesta_bank.diary_demo(pregnancy_id,observed_on,weight_kg,mood,water_glasses,headache,revision) values(p_pregnancy,p_date,p_weight,p_mood,p_water,p_headache,next_rev) returning * into d;
 end if;
 insert into gesta_bank.diary_revision_demo(diary_id,revision,request_id,previous_value,new_value) values(d.id,next_rev,p_request,old_v,v);
 return 'SAVED';
end $$;
revoke all on function gesta_bank.save_diary_demo(uuid,uuid,date,bigint,uuid,numeric,text,integer,boolean) from public,anon,authenticated;
create function gesta_bank.resume_demo(p_profile uuid,p_pregnancy uuid) returns jsonb language sql stable security invoker set search_path='' as $$
 select pg_catalog.jsonb_build_object('fixture',a.fixture,'theme',a.theme,'theme_revision',a.revision,'pregnancy_id',p.id,'ordinal',p.ordinal,'diary',coalesce((select pg_catalog.jsonb_agg(pg_catalog.to_jsonb(d) order by d.observed_on) from gesta_bank.diary_demo d where d.pregnancy_id=p.id),'[]'::jsonb),'clinical',coalesce((select pg_catalog.jsonb_agg(pg_catalog.to_jsonb(v) order by v.observed_on,v.id) from gesta_bank.visit_demo v where v.pregnancy_id=p.id),'[]'::jsonb)) from gesta_bank.profile_demo a join gesta_bank.pregnancy_demo p on p.profile_id=a.id where a.id=p_profile and p.id=p_pregnancy
$$;
revoke all on function gesta_bank.resume_demo(uuid,uuid) from public,anon,authenticated;
