// Who answers for the subject, and who else has a stated responsibility for it, with its kind.
MATCH (who:Element)-[r]->(s:Element {id: $subject}) WHERE type(r) IN ['ANSWERS_FOR', 'OWNS', 'ACCOUNTABLE_FOR', 'MANAGES', 'HEADS', 'APPROVES', 'DECIDES', 'SUPERVISES', 'COORDINATES', 'REVIEWS', 'ADVISES', 'ASSISTS', 'PERFORMS', 'RESPONSIBLE'] RETURN DISTINCT who.id AS who, type(r) AS relation
