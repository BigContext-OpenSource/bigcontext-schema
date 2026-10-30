// Who heads the subject: posts and people, including acting heads; backups are not heads.
MATCH (x:Element)-[:HEADS]->(s:Element {id: $subject}) RETURN DISTINCT x.id AS head
