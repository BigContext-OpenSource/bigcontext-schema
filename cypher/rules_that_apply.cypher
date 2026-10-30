// Every rule that applies to the subject: rules binding it, its units, or the units it is a member of.
MATCH (r:Element)-[:APPLIES_TO]->(s:Element {id: $subject}) RETURN DISTINCT r.id AS rule
