import { serviceClients, Session, cloudApi } from "@yandex-cloud/nodejs-sdk";

const { compute } = cloudApi;

// Идентификатор виртуальной машины с GitLab Runner
const virtualMachineInstanceId = epd5r2e8hequsg87vrrs;

// Токен, который нужно указать при настройке Webhook в GitLab 
const gitlabToken = "<enter token here>"; 

export const handler = async function (request, context) {

  // Проверка значения токена в заголовке
  if (request.headers["X-Gitlab-Token"] !== gitlabToken) {
    console.log("Unauthorized request - end function invocation");
    return {
      statusCode: 401,
    };
  }

  let body = JSON.parse(request.body);

  // Функция обрабатывает только события pipeline
  if (body.object_kind !== "pipeline") {    
    console.log("Object is not a pipeline - end function invocation");
    return {
      statusCode: 200,
    };
  }

  // Если статус "pending", то запускаем ВМ с GitLab Runner
  if (body.object_attributes.detailed_status === "pending") {
    await startInstance(context);
  }

  // Если pipeline успешно завершился, то останавливаем ВМ c GitLab Runner
  if (body.object_attributes.detailed_status === "passed") {
    await stopInstance(context);
  }

  return {
    statusCode: 200,
  };
};

async function startInstance(context) {
  console.log("Starting GitLab Runner VM...");

  const session = new Session({
    iamToken: context.token.access_token,
  });

  const request = compute.instance_service.StartInstanceRequest.fromPartial({
    instanceId: virtualMachineInstanceId,
  });

  const client = session.client(serviceClients.InstanceServiceClient);
  const response = await client.start(request);

  console.log(JSON.stringify(response));
  console.log("GitLab Runner VM has been started");
}

async function stopInstance(context) {
  console.log("Stopping GitLab Runner VM...");

  const session = new Session({
    iamToken: context.token.access_token,
  });

  const request = compute.instance_service.StopInstanceRequest.fromPartial({
    instanceId: virtualMachineInstanceId,
  });

  const client = session.client(serviceClients.InstanceServiceClient);
  const response = await client.stop(request);

  console.log(JSON.stringify(response));
  console.log("GitLab Runner VM has been stopped");
}
