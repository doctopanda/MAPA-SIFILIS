create schema gesta_bank;
revoke all on schema gesta_bank from public,anon,authenticated;
create table gesta_bank.profile_demo(
 id uuid primary key default gen_random_uuid(),
 fixture text not null unique check(fixture ~ '^AURA-DEMO-[0-9]{3}$'),
 theme text not null default 'Aura' check(theme in ('Aura','Coral','Lavanda','Turquesa','Durazno')),
 revision bigint not null default 0 check(revision>=0),
 created_at timestamptz not null default now()
);
create table gesta_bank.pregnancy_demo(
 id uuid primary key default gen_random_uuid(), profile_id uuid not null references gesta_bank.profile_demo(id),
 ordinal integer not null check(ordinal>0), unique(profile_id,ordinal)
);
create table gesta_bank.diary_demo(
 id uuid primary key default gen_random_uuid(), pregnancy_id uuid not null references gesta_bank.pregnancy_demo(id),
 observed_on date not null, weight_kg numeric check(weight_kg between 30 and 250),
 mood text check(mood in ('Tranquila','Con energía','Cansada','Emocionada')),
 water_glasses integer check(water_glasses between 0 and 30), headache boolean,
 unique(pregnancy_id,observed_on), check(weight_kg is not null or mood is not null or water_glasses is not null or headache is not null)
);
create table gesta_bank.visit_demo(
 id uuid primary key default gen_random_uuid(), pregnancy_id uuid not null references gesta_bank.pregnancy_demo(id),
 observed_on date not null, weight_kg numeric check(weight_kg between 30 and 250),
 systolic integer check(systolic between 40 and 250), diastolic integer check(diastolic between 20 and 180),
 check((systolic is null and diastolic is null) or (systolic is not null and diastolic is not null and systolic>diastolic))
);
create table gesta_bank.preference_audit_demo(
 id uuid primary key default gen_random_uuid(), profile_id uuid not null references gesta_bank.profile_demo(id),
 revision bigint not null, previous_theme text not null, new_theme text not null, recorded_at timestamptz not null default now(), unique(profile_id,revision)
);
alter table gesta_bank.profile_demo enable row level security;
alter table gesta_bank.pregnancy_demo enable row level security;
alter table gesta_bank.diary_demo enable row level security;
alter table gesta_bank.visit_demo enable row level security;
alter table gesta_bank.preference_audit_demo enable row level security;
revoke all on all tables in schema gesta_bank from public,anon,authenticated;
create function gesta_bank.set_theme_demo(p_id uuid,p_revision bigint,p_theme text) returns text language plpgsql security invoker set search_path='' as $$
declare r gesta_bank.profile_demo%rowtype;
begin
 if p_id is null or p_revision is null or p_theme is null or p_theme not in ('Aura','Coral','Lavanda','Turquesa','Durazno') then return 'INVALID'; end if;
 select * into r from gesta_bank.profile_demo where id=p_id for update;
 if not found then return 'NOT_FOUND'; end if;
 if r.revision<>p_revision then return 'CONFLICT'; end if;
 if r.theme=p_theme then return 'UNCHANGED'; end if;
 update gesta_bank.profile_demo set theme=p_theme,revision=r.revision+1 where id=p_id;
 insert into gesta_bank.preference_audit_demo(profile_id,revision,previous_theme,new_theme) values(p_id,r.revision+1,r.theme,p_theme);
 return 'SAVED';
end $$;
revoke all on function gesta_bank.set_theme_demo(uuid,bigint,text) from public,anon,authenticated;
insert into gesta_bank.profile_demo(fixture) values('AURA-DEMO-001'),('AURA-DEMO-002');
insert into gesta_bank.pregnancy_demo(profile_id,ordinal) select id,1 from gesta_bank.profile_demo;
insert into gesta_bank.diary_demo(pregnancy_id,observed_on,weight_kg,mood,water_glasses,headache) select p.id,'2026-11-26',68.2,'Tranquila',4,false from gesta_bank.pregnancy_demo p join gesta_bank.profile_demo a on a.id=p.profile_id where a.fixture='AURA-DEMO-001';
insert into gesta_bank.visit_demo(pregnancy_id,observed_on,weight_kg,systolic,diastolic) select p.id,'2026-11-26',68.9,116,74 from gesta_bank.pregnancy_demo p join gesta_bank.profile_demo a on a.id=p.profile_id where a.fixture='AURA-DEMO-001';
comment on schema gesta_bank is 'AURA Imagineary group: private synthetic lab only. No real patients or client grants.';
