const hints = {
  ECONNREFUSED: 'PostgreSQL refused the connection. Start PostgreSQL or check the database host and port in backend/.env.',
  ENOTFOUND: 'The database host could not be found. Check the host name in backend/.env.',
  EAI_AGAIN: 'The database host could not be resolved. Check your network connection and try again.',
  ETIMEDOUT: 'The database connection timed out. Check network access and the database firewall.',
  '28P01': 'PostgreSQL rejected the username or password. Check DATABASE_URL in backend/.env.',
  '28000': 'PostgreSQL rejected access. Check the database authentication and connection settings.',
  '3D000': 'The configured database does not exist. Check the database name in DATABASE_URL.',
  '42P01': 'Required database tables are missing. Run npm.cmd run migrate against your development database before seeding.',
  '42501': 'The database account does not have permission for this operation.',
  DEPTH_ZERO_SELF_SIGNED_CERT: 'The database certificate is not trusted. Use the connection and certificate settings supplied by your database provider.',
};

function describeDatabaseError(error) {
  if (hints[error?.code]) return hints[error.code];
  if (Array.isArray(error?.errors)) {
    const messages = [...new Set(error.errors.map(describeDatabaseError))];
    if (messages.length) return messages.join(' ');
  }
  // Avoid logging connection strings or credentials from driver error messages.
  return 'Database operation failed. Check DATABASE_URL, PostgreSQL availability, and network access.';
}

module.exports = { describeDatabaseError };
