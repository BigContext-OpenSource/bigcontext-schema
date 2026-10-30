// Every unit the subject is a member of, up through the units its teams are part of.
MATCH (s:Element {id: $subject})-[:MEMBER_OF]->(x:Element) RETURN DISTINCT x.id AS unit
