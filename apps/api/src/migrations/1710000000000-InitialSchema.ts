import {
  MigrationInterface,
  QueryRunner,
  Table,
  TableForeignKey,
  TableIndex,
} from 'typeorm';

/** Creates the initial application and Better Auth database schema. */
export class InitialSchema1710000000000 implements MigrationInterface {
  /** Applies the initial database schema. */
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"');

    await queryRunner.createTable(new Table({
      name: 'user',
      columns: [
        { name: 'id', type: 'text', isPrimary: true },
        { name: 'name', type: 'text' },
        { name: 'email', type: 'text', isUnique: true },
        { name: 'emailVerified', type: 'boolean', default: false },
        { name: 'image', type: 'text', isNullable: true },
        { name: 'isAnonymous', type: 'boolean', default: false },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
      ],
    }));

    await queryRunner.createTable(new Table({
      name: 'account',
      columns: [
        { name: 'id', type: 'text', isPrimary: true },
        { name: 'accountId', type: 'text' },
        { name: 'providerId', type: 'text' },
        { name: 'userId', type: 'text' },
        { name: 'accessToken', type: 'text', isNullable: true },
        { name: 'refreshToken', type: 'text', isNullable: true },
        { name: 'idToken', type: 'text', isNullable: true },
        { name: 'accessTokenExpiresAt', type: 'timestamp', isNullable: true },
        { name: 'refreshTokenExpiresAt', type: 'timestamp', isNullable: true },
        { name: 'scope', type: 'text', isNullable: true },
        { name: 'password', type: 'text', isNullable: true },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
      ],
    }));
    await queryRunner.createIndex('account', new TableIndex({
      name: 'IDX_account_userId', columnNames: ['userId'],
    }));
    await queryRunner.createForeignKey('account', new TableForeignKey({
      name: 'FK_account_userId', columnNames: ['userId'],
      referencedTableName: 'user', referencedColumnNames: ['id'], onDelete: 'CASCADE',
    }));

    await queryRunner.createTable(new Table({
      name: 'session',
      columns: [
        { name: 'id', type: 'text', isPrimary: true },
        { name: 'expiresAt', type: 'timestamp' },
        { name: 'token', type: 'text', isUnique: true },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
        { name: 'ipAddress', type: 'text', isNullable: true },
        { name: 'userAgent', type: 'text', isNullable: true },
        { name: 'userId', type: 'text' },
      ],
    }));
    await queryRunner.createIndex('session', new TableIndex({
      name: 'IDX_session_userId', columnNames: ['userId'],
    }));
    await queryRunner.createForeignKey('session', new TableForeignKey({
      name: 'FK_session_userId', columnNames: ['userId'],
      referencedTableName: 'user', referencedColumnNames: ['id'], onDelete: 'CASCADE',
    }));

    await queryRunner.createTable(new Table({
      name: 'verification',
      columns: [
        { name: 'id', type: 'text', isPrimary: true },
        { name: 'identifier', type: 'text' },
        { name: 'value', type: 'text' },
        { name: 'expiresAt', type: 'timestamp' },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
      ],
    }));
    await queryRunner.createIndex('verification', new TableIndex({
      name: 'IDX_verification_identifier', columnNames: ['identifier'],
    }));

    await queryRunner.createTable(new Table({
      name: 'player_accounts',
      columns: [
        { name: 'id', type: 'uuid', isPrimary: true, default: 'uuid_generate_v4()' },
        { name: 'authUserId', type: 'varchar', isUnique: true },
        { name: 'displayName', type: 'varchar' },
        { name: 'email', type: 'varchar', isNullable: true },
        { name: 'image', type: 'varchar', isNullable: true },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
      ],
    }));

    await queryRunner.createTable(new Table({
      name: 'saved_decks',
      columns: [
        { name: 'id', type: 'uuid', isPrimary: true, default: 'uuid_generate_v4()' },
        { name: 'ownerId', type: 'uuid' },
        { name: 'name', type: 'varchar' },
        { name: 'leaderCardId', type: 'varchar' },
        { name: 'cards', type: 'jsonb' },
        { name: 'createdAt', type: 'timestamp', default: 'now()' },
        { name: 'updatedAt', type: 'timestamp', default: 'now()' },
      ],
    }));
    await queryRunner.createForeignKey('saved_decks', new TableForeignKey({
      name: 'FK_saved_decks_ownerId', columnNames: ['ownerId'],
      referencedTableName: 'player_accounts', referencedColumnNames: ['id'], onDelete: 'CASCADE',
    }));
  }

  /** Reverts the initial database schema. */
  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropForeignKey('saved_decks', 'FK_saved_decks_ownerId');
    await queryRunner.dropTable('saved_decks');
    await queryRunner.dropTable('player_accounts');
    await queryRunner.dropForeignKey('session', 'FK_session_userId');
    await queryRunner.dropTable('session');
    await queryRunner.dropForeignKey('account', 'FK_account_userId');
    await queryRunner.dropTable('account');
    await queryRunner.dropTable('verification');
    await queryRunner.dropTable('user');
    await queryRunner.query('DROP EXTENSION IF EXISTS "uuid-ossp"');
  }
}
