-- 1. Enable the pgvector extension
create extension if not exists vector;

-- 2. Knowledge base table (768 dimensions, matching Gemini embeddings)
create table if not exists incident_docs (
    id bigserial primary key,
    content text not null,
    metadata jsonb default '{}'::jsonb,
    embedding vector(768)
);

-- 3. Semantic similarity search function (RPC)
create or replace function match_incident_docs (
    query_embedding vector(768),
    match_count int default 3,
    filter jsonb default '{}'::jsonb
) returns table (
    id bigint,
    content text,
    metadata jsonb,
    similarity float
)
language plpgsql
as $$
begin
    return query
    select
        id,
        content,
        metadata,
        1 - (incident_docs.embedding <=> query_embedding) as similarity
    from incident_docs
    where metadata @> filter
    order by incident_docs.embedding <=> query_embedding
    limit match_count;
end;
$$;
