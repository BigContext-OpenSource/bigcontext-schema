// Every rule the subject takes precedence over, including through rule sets.
MATCH (s:Element {id: $subject})-[:OVERRIDES]->(x:Element) RETURN DISTINCT x.id AS beaten
