CREATE TABLE IF NOT EXISTS aln_illegal_containers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL,
    stash_id VARCHAR(100) NOT NULL,
    cooler_id VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY citizenid_unique (citizenid)
);