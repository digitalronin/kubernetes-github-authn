# See log output from the github-authn app

    stern -l app=github-authn

You should see output when you hit the app. like this:

    curl -v https://github-authn.apps.david-auth.cloud-platform.service.justice.gov.uk/authenticate

# Access the kubernetes API using a bearer token

    export CLUSTER_NAME=david-auth.cloud-platform.service.justice.gov.uk
    export APISERVER="https://api.${CLUSTER_NAME}"

    # Don't do this. Use the `id-token` from the .kube/config file you got via auth0
    export TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}" | base64 --decode)

    curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure

# Setting up

## Deploy this app. on the cluster

    kubectl apply -f cloud-platform-deploy/

## Configure kops to use webhook token authentication

* Add an entry to `spec.fileAssets` in the kops config

      - content: |
          kind: Config
          apiVersion: v1
          preferences: {}
          clusters:
          - name: github-authn
            cluster:
              server: https://github-authn.apps.david-auth.cloud-platform.service.justice.gov.uk/authenticate
          users:
          - name: authn-apiserver
            user:
              token: secret
          contexts:
          - name: webhook
            context:
              cluster: github-authn
              user: authn-apiserver
          current-context: webhook
        name: token-webhook-config.yaml
        path: /srv/kubernetes/token-webhook-config.yaml
        roles:
        - Master

* Add `spec.kubeAPIServer.authenticationTokenWebhookConfigFile` with value `/srv/kubernetes/token-webhook-config.yaml`

# TODO

* Figure out how to get auth0 to give users a minimal file which *only* has an id-token in it. There seem to be multiple authentication options in the file as it is now.
* Rewrite the authn app. so I can see a lot more of what's going on
