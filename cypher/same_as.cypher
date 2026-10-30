// Every element, in this source or a linked one, decided to stand for the same thing as the subject.
MATCH (s:Element {id: $subject})-[:SAME_AS]-(x:Element) WHERE x.id <> s.id RETURN DISTINCT x.id AS same
