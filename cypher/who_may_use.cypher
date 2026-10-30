// Who may use or see the subject, and how.
MATCH (who:Element)-[r]->(s:Element {id: $subject}) WHERE type(r) IN ['CAN_USE', 'CAN_READ', 'CAN_ADMIN', 'CAN_SEE_MASKED', 'ACCESS_GRANTED'] RETURN DISTINCT who.id AS who, type(r) AS access
