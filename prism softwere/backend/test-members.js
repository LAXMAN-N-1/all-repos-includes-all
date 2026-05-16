const { ProjectMember, User } = require('./src/models');

async function test() {
    try {
        const members = await ProjectMember.findAll({
            where: { projectId: '80c9fcd3-9dec-48e7-a8e7-f9d4d5a9814b' },
            include: [{ model: User, as: 'user' }]
        });
        console.log(`FOUND_MEMBERS: ${members.length}`);
        for (const m of members) {
            console.log(`- ${m.user ? m.user.email : 'No user'} (Role: ${m.role})`);
        }
    } catch (e) {
        console.error(e);
    } finally {
        process.exit();
    }
}
test();
