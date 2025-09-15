Using the Atlassian MCP, get all tickets from the current active sprint for Developer Efficiency board (ID: 373) that are
  assigned to me. Organize them by status (In Progress, Review & Validation, Done, Backlog) and include:

  1. Ticket key, summary, issue type, and priority for each
  2. Sprint metrics showing count and percentage for each status
  3. Key focus areas based on ticket themes
  4. Use appropriate status emojis and clear formatting

  JQL Query: `sprint in openSprints() AND assignee = currentUser() ORDER BY status, priority DESC`
  Cloud ID: Use getAccessibleAtlassianResources to get the Whatfix cloud ID
  Fields: ["key", "summary", "status", "issuetype", "priority", "created", "updated", "labels", "components"]

  Usage Instructions:
  1. Replace board ID 373 with your target board ID
  2. The prompt will automatically use your current user account
  3. Modify the JQL query if you need different filtering criteria
  4. Adjust the fields array if you need additional metadata
