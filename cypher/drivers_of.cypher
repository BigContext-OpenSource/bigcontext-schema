// What drives the subject, kept apart from what its formula depends on.
MATCH (d:Element)-[r]->(s:Element {id: $subject}) WHERE type(r) IN ['INCREASES', 'DECREASES', 'INFLUENCES'] RETURN DISTINCT d.id AS driver, type(r) AS how
