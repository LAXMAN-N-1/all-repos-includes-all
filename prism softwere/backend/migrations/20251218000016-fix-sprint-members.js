'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
    async up(queryInterface, Sequelize) {
        const transaction = await queryInterface.sequelize.transaction();
        try {
            const tables = await queryInterface.showAllTables();
            const existingTables = new Set(tables);

            const findTable = (name) => {
                if (existingTables.has(name)) return name;
                for (const t of existingTables) {
                    if (t.toLowerCase() === name.toLowerCase()) return t;
                }
                return null;
            };

            const sprintMembersTable = findTable('SprintMembers');

            if (!sprintMembersTable) {
                console.log('Creating SprintMembers table');
                await queryInterface.createTable('SprintMembers', {
                    id: {
                        type: Sequelize.UUID,
                        defaultValue: Sequelize.UUIDV4,
                        primaryKey: true,
                    },
                    sprintId: {
                        type: Sequelize.UUID,
                        allowNull: false,
                        references: {
                            model: 'Sprints',
                            key: 'id',
                        },
                        onDelete: 'CASCADE',
                        field: 'sprint_id'
                    },
                    userId: {
                        type: Sequelize.UUID,
                        allowNull: false,
                        references: {
                            model: 'Users',
                            key: 'id',
                        },
                        onDelete: 'CASCADE',
                        field: 'user_id'
                    },
                    role: {
                        type: Sequelize.STRING,
                        allowNull: true,
                    },
                    capacityHours: {
                        type: Sequelize.DECIMAL(10, 2),
                        allowNull: true,
                        defaultValue: 0,
                        field: 'capacity_hours'
                    },
                    createdAt: {
                        type: Sequelize.DATE,
                        allowNull: false,
                        field: 'created_at'
                    },
                    updatedAt: {
                        type: Sequelize.DATE,
                        allowNull: false,
                        field: 'updated_at'
                    },
                }, { transaction });

                // Add unique constraint with a new name to avoid collision
                await queryInterface.addConstraint('SprintMembers', {
                    fields: ['sprint_id', 'user_id'],
                    type: 'unique',
                    name: 'unique_sprint_member_v2', // Changed name to avoid collision
                    transaction
                });

            } else {
                // If table exists, ensure casing
                if (sprintMembersTable !== 'SprintMembers') {
                    console.log(`Renaming ${sprintMembersTable} -> SprintMembers`);
                    await queryInterface.renameTable(sprintMembersTable, 'SprintMembers', { transaction });
                }
            }

            await transaction.commit();
        } catch (error) {
            await transaction.rollback();
            throw error;
        }
    },

    async down(queryInterface, Sequelize) {
        // Reversal
    }
};
