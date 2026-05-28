import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";

const client = DynamoDBDocumentClient.from(new DynamoDBClient({}));

export const handler = async (event) => {
  const { userId, email } = event;

  const result = await client.send(new GetCommand({
    TableName: "Users",
    Key: { userId, email }
  }));

  return result.Item
    ? { statusCode: 200, body: JSON.stringify(result.Item) }
    : { statusCode: 404, body: "User not found" };
};
