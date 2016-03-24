CREATE TABLE d_file_types(
    id integer primary key
  , type text
  , desc text
);

insert into d_file_types (type,desc) values (null,'not file type instruction');
insert into d_file_types (type,desc) values ('i', 'input file name');
insert into d_file_types (type,desc) values ('o', 'output file name');
insert into d_file_types (type,desc) values ('t', 'true - is file name');
insert into d_file_types (type,desc) values ('f', 'false - is not file name');

CREATE TABLE templates(
    id integer primary key autoincrement
  , app_id
  , app_name
  , input_file_name
  , create_date
);

CREATE TABLE blocks (
    id integer primary key autoincrement
  , name text not null
  , template_id integer not null
  , seq_id integer not null
  , foreign key(template_id) references templates(id) on delete cascade on update cascade
);

CREATE TABLE block_tags(
    id INTEGER PRIMARY KEY AUTOINCREMENT
  , block_id INTEGER NOT NULL
  , tag CHAR(50) NOT NULL
  , foreign key(block_id) REFERENCES blocks(id) on delete cascade on update cascade
);

CREATE UNIQUE INDEX block_tag_unq ON block_tags (block_id ASC, tag ASC);

CREATE TABLE block_comments(
    id integer primary key autoincrement
  , text text
  , block_id integer not null
  , seq_id integer not null
  , foreign key(block_id) references blocks(id) on delete cascade on update cascade
);

CREATE TABLE instructions(
    id integer primary key autoincrement
  , parm string not null
  , arg string
  , block_id integer not null
  , seq_id integer not null
  , foreign key(block_id) references blocks(id) on delete cascade on update cascade
);

CREATE TABLE instruction_tags(
    id INTEGER PRIMARY KEY AUTOINCREMENT
  , instruction_id INTEGER NOT NULL
  , tag CHAR(50) NOT NULL
  , foreign key(instruction_id) REFERENCES instructions(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX instruction_tag_unq ON instruction_tags (instruction_id ASC, tag ASC);

PRAGMA FOREIGN_KEYS = on;

