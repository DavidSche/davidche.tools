db.createUser({
    user: 'application_user',
    pwd: 'application_pass',
    roles: [
        {
            role: 'dbOwner',
            db: 'application_database',
        },
    ],
});