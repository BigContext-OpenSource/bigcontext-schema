// Every metric the subject feeds, directly or through other metrics.
MATCH (s:Element {id: $subject})-[:FEEDS]->(x:Element) RETURN DISTINCT x.id AS metric
