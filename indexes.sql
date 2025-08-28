-- Index 1: Foreign key for airline lookups, used commonly for searching for flights by airline or for details checking after booking
CREATE INDEX idx_flight_airline ON Flight(airline_id);

-- Index 2: Composite index for both source and destination airports, usually paired together during real searches (e.g., from A to B)
CREATE INDEX idx_flight_source_dest ON Flight(source_city_id, destination_city_id);

-- Index 3: Composite index for departure time + arrival time, also paired during certain times, especially for business clients having events to attend
CREATE INDEX idx_flight_departure_arrival ON Flight(departure_time_id, arrival_time_id);

-- Index 4: Flight code lookup (business identifier, often queried in the business or management side of the system)
CREATE INDEX idx_flight_code ON Flight(flight_code);

-- Index 5: Price-based searches (e.g., find cheapest flights, or certain price range acceptable by client)
CREATE INDEX idx_flight_price ON Flight(price);
