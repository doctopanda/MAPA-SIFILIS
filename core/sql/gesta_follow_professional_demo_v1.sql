-- Private synthetic laboratory; no authentication or client grants.
create table gesta_bank.professional_demo(
 id uuid primary key default gen_random_uuid(), fixture text unique not null check(fixture ~ '^PRO-DEMO-[0-9]{3}$'),
 profession text not null check(profession in ('MEDICINA','ENFERMERIA')),
 credential text unique not null check(credential ~ '^CED-DEMO-[0-9]{3}$'),
 institution text not null check(institution='INSTITUCION FICTICIA'),
 unit_code text not null check(unit_code in ('TEST-CLUES-001','TEST-CLUES-002')),
 status text not null default 'PENDING' check(status in ('PENDING','VERIFIED','SUSPENDED'))
);
create table gesta_bank.relationship_demo(
 id uuid primary key default gen_random_uuid(), professional_id uuid not null references gesta_bank.professional_demo(id),
 pregnancy_id uuid not null references gesta_bank.pregnancy_demo(id),
 unit_code text not null check(unit_code in ('TEST-CLUES-001','TEST-CLUES-002')),
 mode text not null check(mode in ('TEMPORARY','FOLLOW')),
 approved_at timestamptz not null, expires_at timestamptz not null,
 revoked_at timestamptz, diary_shared boolean not null default false,
 check(expires_at>approved_at), check(revoked_at is null or revoked_at>=approved_at),
 check(mode<>'TEMPORARY' or expires_at<=approved_at+interval '30 minutes')
);
create table gesta_bank.study_demo(
 id uuid primary key default gen_random_uuid(), pregnancy_id uuid not null references gesta_bank.pregnancy_demo(id),
 kind text not null check(kind in ('LAB','USG')), fixture text not null check(fixture ~ '^STUDY-DEMO-[0-9]{3}$'),
 verified boolean not null default false, recorded_at timestamptz not null, unique(pregnancy_id,fixture)
);
create table gesta_bank.private_diary_demo(
 id uuid primary key default gen_random_uuid(), pregnancy_id uuid not null references gesta_bank.pregnancy_demo(id),
 observed_on date not null, fixture text not null check(fixture in ('PRIVATE-DEMO-A','PRIVATE-DEMO-B')), unique(pregnancy_id,observed_on)
);
create table gesta_bank.access_audit_demo(
 id uuid primary key default gen_random_uuid(), professional_id uuid not null references gesta_bank.professional_demo(id),
 relationship_id uuid not null references gesta_bank.relationship_demo(id), accessed_at timestamptz not null, result text not null check(result in ('ALLOWED','DENIED'))
);
alter table gesta_bank.professional_demo enable row level security;
alter table gesta_bank.relationship_demo enable row level security;
alter table gesta_bank.study_demo enable row level security;
alter table gesta_bank.private_diary_demo enable row level security;
alter table gesta_bank.access_audit_demo enable row level security;
revoke all on all tables in schema gesta_bank from public,anon,authenticated;
create function gesta_bank.follow_read_demo(p_actor uuid,p_link uuid,p_now timestamptz,p_mfa boolean,p_session_live boolean)
returns jsonb language plpgsql security invoker set search_path='' as $$
declare r gesta_bank.relationship_demo%rowtype; a gesta_bank.professional_demo%rowtype;
begin
 select * into r from gesta_bank.relationship_demo where id=p_link for share;
 select * into a from gesta_bank.professional_demo where id=p_actor for share;
 if r.id is null or a.id is null then return jsonb_build_object('status','DENIED');end if;
 if p_now is null or p_mfa is distinct from true or p_session_live is distinct from true or a.status<>'VERIFIED' or r.professional_id<>a.id or a.unit_code<>r.unit_code or r.revoked_at is not null or p_now<r.approved_at or p_now>=r.expires_at then
 insert into gesta_bank.access_audit_demo(professional_id,relationship_id,accessed_at,result) values(a.id,r.id,coalesce(p_now,now()),'DENIED');
 return jsonb_build_object('status','DENIED');end if;
 insert into gesta_bank.access_audit_demo(professional_id,relationship_id,accessed_at,result) values(a.id,r.id,p_now,'ALLOWED');
 return jsonb_build_object('status','ALLOWED','pregnancy_id',r.pregnancy_id,
 'clinical',coalesce((select jsonb_agg(to_jsonb(v) order by v.observed_on,v.id) from gesta_bank.visit_demo v where v.pregnancy_id=r.pregnancy_id and v.observed_on<=(p_now at time zone 'America/Hermosillo')::date),'[]'::jsonb),
 'studies',coalesce((select jsonb_agg(to_jsonb(s) order by s.recorded_at,s.id) from gesta_bank.study_demo s where s.pregnancy_id=r.pregnancy_id and s.verified and s.recorded_at<=p_now),'[]'::jsonb),
 'diary',case when r.diary_shared then coalesce((select jsonb_agg(to_jsonb(d) order by d.observed_on) from gesta_bank.diary_demo d where d.pregnancy_id=r.pregnancy_id and d.observed_on<=(p_now at time zone 'America/Hermosillo')::date),'[]'::jsonb) else '[]'::jsonb end,
 'diary_shared',r.diary_shared);
end $$;
revoke all on function gesta_bank.follow_read_demo(uuid,uuid,timestamptz,boolean,boolean) from public,anon,authenticated;
comment on function gesta_bank.follow_read_demo(uuid,uuid,timestamptz,boolean,boolean) is 'Synthetic contract only. Caller-supplied actor, clock, MFA and session flags are not real authentication. Never expose to clients.';
insert into gesta_bank.professional_demo(fixture,profession,credential,institution,unit_code,status) values
('PRO-DEMO-001','MEDICINA','CED-DEMO-001','INSTITUCION FICTICIA','TEST-CLUES-001','VERIFIED'),
('PRO-DEMO-002','ENFERMERIA','CED-DEMO-002','INSTITUCION FICTICIA','TEST-CLUES-001','PENDING');
insert into gesta_bank.study_demo(pregnancy_id,kind,fixture,verified,recorded_at)
select p.id,'LAB','STUDY-DEMO-001',true,'2026-11-26T08:00:00-07' from gesta_bank.pregnancy_demo p join gesta_bank.profile_demo a on a.id=p.profile_id where a.fixture='AURA-DEMO-001';
insert into gesta_bank.private_diary_demo(pregnancy_id,observed_on,fixture)
select p.id,'2026-11-26','PRIVATE-DEMO-A' from gesta_bank.pregnancy_demo p join gesta_bank.profile_demo a on a.id=p.profile_id where a.fixture='AURA-DEMO-001';
