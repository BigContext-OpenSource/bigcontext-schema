// Everything in the category or level the subject names, including what is in a kind of it.
MATCH (x:Element)-[:IS_A]->(s:Element {id: $subject}) RETURN DISTINCT x.id AS member
