// Everyone who is a member of the subject, including members of the teams inside it.
MATCH (x:Element)-[:MEMBER_OF]->(s:Element {id: $subject}) RETURN DISTINCT x.id AS member
