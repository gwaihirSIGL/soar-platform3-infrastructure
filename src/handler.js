const { Client } = require('pg')
const { ipLookup, urlLookup } = require('./helpers')

module.exports.hello = async (event) => {
  console.log('env:', process.env)
  const [dbDnsResponse, dnsResponse] = await Promise.all([
    ipLookup(process.env.PGHOST),
    ipLookup('encrypted.google.com')
  ])

  console.log({ dnsResponse, dbDnsResponse })

  const url = 'https://encrypted.google.com'
  const httpResponse = await urlLookup(url)

  // When client.end() is called, we need to create a new client
  // each invocation
  const client = new Client({
    connectionTimeoutMillis: 10 * 1000,
    query_timeout: 10 * 1000
  })

  let dbResponse
  try {
    await client.connect()
    const dbRes = await client.query(
      "CREATE TABLE IF NOT EXISTS users (\
        id serial PRIMARY KEY,\
        resp VARCHAR ( 255 )\
     );\
     INSERT INTO users(resp)\
     VALUES ('TTwalid');\
     RETURNING *"
    )
    dbResponse = dbRes
  } catch (e) {
    dbResponse = `ERROR: ${e.message}`
  } finally {
    await client.end()
  }

  return {
    message: 'Very much success!!!',
    dbResponse,
    dnsResponse,
    dbDnsResponse,
    responseHeader: httpResponse,
    event
  }
}

module.exports.getUsers = async (event) => {
  console.log('env:', process.env)
  const [dbDnsResponse, dnsResponse] = await Promise.all([
    ipLookup(process.env.PGHOST),
    ipLookup('encrypted.google.com')
  ])

  console.log({ dnsResponse, dbDnsResponse })

  const url = 'https://encrypted.google.com'
  const httpResponse = await urlLookup(url)

  // When client.end() is called, we need to create a new client
  // each invocation
  const client = new Client({
    connectionTimeoutMillis: 10 * 1000,
    query_timeout: 10 * 1000
  })

  let dbResponse
  try {
    await client.connect()
    const dbRes = await client.query('SELECT * from users')
    dbResponse = dbRes.rows[0]
  } catch (e) {
    dbResponse = `ERROR: ${e.message}`
  } finally {
    await client.end()
  }

  return {
    message: 'Very much success!!!',
    dbResponse,
    dnsResponse,
    dbDnsResponse,
    responseHeader: httpResponse,
    event
  }
}

module.exports.UpdateUsers = async (event) => {
  console.log('env:', process.env)
  // When client.end() is called, we need to create a new client
  // each invocation
  const client = new Client({
    connectionTimeoutMillis: 10 * 1000,
    query_timeout: 10 * 1000
  })

  let dbResponse
  try {
    await client.connect()
    const dbRes = await client.query('SELECT * from users')
    dbResponse = dbRes.rows[0]
  } catch (e) {
    dbResponse = `ERROR: ${e.message}`
  } finally {
    await client.end()
  }

  return {
    message: 'Very much success!!!',
    dbResponse,
    event
  }
}
