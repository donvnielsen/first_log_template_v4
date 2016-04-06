CREATE TABLE fl_templates(
    id integer primary key autoincrement
  , app_id
  , app_name
  , input_file_name
  , create_date
);

CREATE TABLE fl_blocks (
    id integer primary key autoincrement
  , name text not null
  , template_id integer not null
  , seq_id integer not null
  , foreign key(template_id) references fl_templates(id) on delete cascade on update cascade
);

CREATE TABLE fl_block_tags(
    id INTEGER PRIMARY KEY AUTOINCREMENT
  , block_id INTEGER NOT NULL
  , tag CHAR(50) NOT NULL
  , foreign key(block_id) REFERENCES fl_blocks(id) on delete cascade on update cascade
);

CREATE UNIQUE INDEX block_tag_unq ON fl_block_tags (block_id ASC, tag ASC);

CREATE TABLE fl_block_comments(
    id integer primary key autoincrement
  , text text
  , block_id integer not null
  , seq_id integer not null
  , foreign key(block_id) references fl_blocks(id) on delete cascade on update cascade
);

CREATE TABLE fl_instructions(
    id integer primary key autoincrement
  , parm string not null
  , arg string
  , block_id integer not null
  , seq_id integer not null
  , foreign key(block_id) references fl_blocks(id) on delete cascade on update cascade
);

CREATE TABLE fl_instruction_tags(
    id INTEGER PRIMARY KEY AUTOINCREMENT
  , instruction_id INTEGER NOT NULL
  , tag CHAR(50) NOT NULL
  , foreign key(instruction_id) REFERENCES fl_instructions(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX instruction_tag_unq ON fl_instruction_tags (instruction_id ASC, tag ASC);

PRAGMA FOREIGN_KEYS = on;

