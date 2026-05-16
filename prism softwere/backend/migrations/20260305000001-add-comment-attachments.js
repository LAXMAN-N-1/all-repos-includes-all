'use strict';

module.exports = {
    async up(queryInterface, Sequelize) {
        // Add comment_id to Attachments table (nullable FK to Comments)
        await queryInterface.addColumn('Attachments', 'comment_id', {
            type: Sequelize.UUID,
            allowNull: true,
            references: {
                model: 'Comments',
                key: 'id',
            },
            onDelete: 'CASCADE',
        });

        // Add index on comment_id for fast lookups
        await queryInterface.addIndex('Attachments', ['comment_id'], {
            name: 'attachments_comment_id_idx',
        });
    },

    async down(queryInterface) {
        await queryInterface.removeIndex('Attachments', 'attachments_comment_id_idx');
        await queryInterface.removeColumn('Attachments', 'comment_id');
    },
};
