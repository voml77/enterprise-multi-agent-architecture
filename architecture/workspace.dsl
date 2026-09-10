workspace "Enterprise Multi-Agent Architecture" "Reference architecture for governed enterprise multi-agent systems" {

    !identifiers hierarchical

    model {
        user = person "Enterprise User" "Business or technical user interacting with the platform."

        enterpriseApplications = softwareSystem "Enterprise Applications" "Authorized enterprise applications and APIs consuming governed platform capabilities."

        enterpriseIam = softwareSystem "Enterprise IAM" "Authoritative enterprise identity and access management system for identities, roles, groups and entitlements."

        operationalSystems = softwareSystem "Operational Enterprise Systems" "Systems of record providing governed operational enterprise data."

        researchSources = softwareSystem "Approved External Research Sources" "Policy-approved external sources used for governed research when trusted enterprise knowledge is insufficient."

        externalModelProviders = softwareSystem "Approved External Model Providers" "Approved external providers supplying eligible model execution capabilities."

        platform = softwareSystem "Enterprise Multi-Agent Platform" "Governed platform for agentic enterprise assistance." {

            group "Experience Plane" {

                experienceGateway = container "Experience Gateway" "Provides governed entry points for users, applications and APIs." {
                    tags "Experience"
                }
            }

            group "Orchestration Plane" {

                orchestrationService = container "Orchestration Service" "Deterministically coordinates requests, capabilities and task execution." {
                    tags "Orchestration"
                }

                policyService = container "Policy Decision Service" "Evaluates authorization, execution and governance policies." {
                    tags "Orchestration"
                }

                contextService = container "Context Assembly Service" "Builds policy-scoped context for bounded agent execution." {
                    tags "Orchestration"
                }

                taskState = container "Task State Store" "Persists canonical task and execution state independently of individual agents." {
                    tags "State"
                }
            }

            group "Agent & Capability Plane" {

                domainAgent = container "Domain Support Agent" "Performs domain-specific reasoning within a bounded Domain Contract." {
                    tags "Agent"
                }

                analysisAgent = container "Analysis Agent" "Performs iterative analytical reasoning over governed enterprise data." {
                    tags "Agent"
                }

                researchAgent = container "Research Agent" "Acquires external knowledge when trusted enterprise knowledge is insufficient and policy permits research." {
                    tags "Agent"
                }

                retrievalService = container "Knowledge Retrieval Service" "Retrieves trusted enterprise knowledge through governed semantic retrieval." {
                    tags "Service"
                }

                graphService = container "Graph Query Service" "Provides governed traversal and queries over enterprise relationships." {
                    tags "Service"
                }
                
                dataAccessService = container "Enterprise Data Access Service" "Mediates policy-controlled access to approved operational enterprise data." {
                    tags "Service"
                }

                artifactEvidenceService = container "Artifact & Evidence Service" "Persists generated work products, findings and evidence packages." {
                    tags "Service"
                }

                workflowService = container "Workflow Service" "Executes approved side-effecting actions against enterprise systems." {
                    tags "Service"
                }
            }

            group "Governance & Control Plane" {

                curationService = container "Knowledge Curation Service" "Transforms eligible findings and evidence into governed knowledge candidates." {
                    tags "Governance"
                }

                promotionService = container "Validation & Promotion Service" "Validates, reviews and promotes approved candidates into canonical enterprise knowledge." {
                    tags "Governance"
                }

                indexMaintenanceService = container "Index Maintenance Service" "Maintains the derived semantic retrieval index from approved canonical knowledge." {
                    tags "Governance"
                }

                graphLifecycleService = container "Graph Lifecycle Service" "Maintains governed canonical relationships in the enterprise knowledge graph." {
                    tags "Governance"
                }

                evaluationService = container "Evaluation Service" "Evaluates capability quality, runtime qualification and production behaviour." {
                    tags "Governance"
                }

                auditService = container "Audit Service" "Records append-only audit events for governed actions and decisions." {
                    tags "Governance"
                }

                observabilityService = container "Observability Service" "Collects operational telemetry, traces and metrics across governed platform execution without treating business payloads as telemetry by default." {
                    tags "Governance"
                }

                dataClassificationService = container "Data Classification Service" "Classifies execution context, data sensitivity and disclosure constraints for governed model execution." {
                    tags "Governance"
                }

                disclosureTransformationPolicyService = container "Disclosure Transformation Policy Service" "Determines required disclosure transformations for the intended capability and processing class." {
                    tags "Governance"
                }

                dataTransformationService = container "Data Transformation Service" "Applies approved redaction, masking, pseudonymization, aggregation or generalization to execution-scoped data." {
                    tags "Governance"
                }

                transformationValidationService = container "Transformation Validation Service" "Validates transformed payloads and assesses residual disclosure and re-identification risk." {
                    tags "Governance"
                }

                modelExecutionPolicyService = container "Model Execution Policy Service" "Determines eligible model runtimes from validated disclosure risk, capability requirements and execution policy." {
                    tags "Governance"
                }

                approvalService = container "Approval Service" "Coordinates required human approval for governed side-effecting actions before execution." {
                    tags "Governance"
                }
            }

            group "Enterprise Data & Knowledge Plane" {

                candidateStore = container "Candidate Knowledge Store" "Stores unverified knowledge candidates in a separate trust domain." {
                    tags "Candidate" "Database"
                }

                canonicalStore = container "Canonical Knowledge Store" "Stores approved, versioned enterprise knowledge and authoritative metadata." {
                    tags "Canonical" "Database"
                }

                semanticIndex = container "Semantic Retrieval Index" "Derived semantic locator referencing canonical knowledge artifacts." {
                    tags "Derived" "Database"
                }

                knowledgeGraph = container "Enterprise Knowledge Graph" "Stores governed enterprise entities and canonical relationships." {
                    tags "Graph" "Database"
                }

                artifactStore = container "Artifact Store" "Stores generated reports, evidence packages and large knowledge artifacts." {
                    tags "Artifact" "Database"
                }
            }

            group "Model Runtime Plane" {

                localRuntime = container "Local Model Runtime" "Executes approved capabilities on locally operated models." {
                    tags "Runtime"
                }

                privateRuntime = container "Private / Sovereign Runtime" "Executes eligible capabilities in approved private or sovereign infrastructure." {
                    tags "Runtime"
                }

                externalRuntime = container "Approved External Runtime" "Executes eligible capabilities using approved external model providers." {
                    tags "Runtime"
                }
            }
        }

        user -> platform "Uses for governed enterprise assistance"

        enterpriseApplications -> platform "Uses governed platform capabilities"

        enterpriseApplications -> platform.experienceGateway "Invokes governed platform capabilities"

        platform -> enterpriseIam "Authenticates identities and resolves entitlements"

        platform -> operationalSystems "Accesses governed operational data"

        platform -> researchSources "Acquires external evidence when policy permits"

        platform -> externalModelProviders "Invokes eligible external model capabilities"

        user -> platform.experienceGateway "Uses"

        platform.experienceGateway -> platform.orchestrationService "Submits requests to"

        platform.orchestrationService -> platform.policyService "Requests policy decision"
        platform.orchestrationService -> platform.contextService "Requests scoped context"
        platform.orchestrationService -> platform.taskState "Reads and updates task state"

        platform.orchestrationService -> platform.domainAgent "Assigns bounded domain tasks"
        platform.orchestrationService -> platform.analysisAgent "Assigns analytical tasks"
        platform.orchestrationService -> platform.researchAgent "Assigns approved research tasks"

        platform.domainAgent -> platform.retrievalService "Requests trusted knowledge"
        platform.domainAgent -> platform.graphService "Requests enterprise relationships"

        platform.analysisAgent -> platform.retrievalService "Requests trusted knowledge"
        platform.analysisAgent -> platform.graphService "Requests enterprise relationships"
        platform.analysisAgent -> platform.dataAccessService "Requests approved enterprise data"

        platform.researchAgent -> platform.artifactEvidenceService "Produces findings and evidence"

        platform.retrievalService -> platform.semanticIndex "Searches"
        platform.retrievalService -> platform.canonicalStore "Rehydrates canonical artifacts"
        platform.graphService -> platform.knowledgeGraph "Queries"
        platform.artifactEvidenceService -> platform.artifactStore "Persists artifacts and evidence"

        platform.artifactEvidenceService -> platform.curationService "Provides eligible findings and evidence"
        platform.curationService -> platform.candidateStore "Creates governed candidates"
        platform.candidateStore -> platform.promotionService "Submits candidates for validation"
        platform.promotionService -> platform.canonicalStore "Promotes approved knowledge"

        platform.promotionService -> platform.indexMaintenanceService "Triggers index maintenance"
        platform.indexMaintenanceService -> platform.canonicalStore "Reads approved canonical knowledge"
        platform.indexMaintenanceService -> platform.semanticIndex "Maintains derived semantic index"

        platform.promotionService -> platform.graphLifecycleService "Submits approved relationship changes"
        platform.graphLifecycleService -> platform.knowledgeGraph "Maintains governed canonical relationships"

        platform.domainAgent -> platform.workflowService "Requests governed actions"
        platform.analysisAgent -> platform.workflowService "Requests governed actions"
        platform.analysisAgent -> platform.artifactEvidenceService "Produces analyses and evidence"

        platform.workflowService -> platform.policyService "Requests execution authorization"
        platform.policyService -> platform.approvalService "Requests required human approval"
        platform.approvalService -> platform.workflowService "Returns approval decision"

        platform.orchestrationService -> platform.auditService "Emits orchestration audit events"
        platform.workflowService -> platform.auditService "Emits action audit events"
        platform.curationService -> platform.auditService "Emits curation audit events"
        platform.promotionService -> platform.auditService "Emits promotion audit events"
        platform.indexMaintenanceService -> platform.auditService "Emits index maintenance audit events"
        platform.graphLifecycleService -> platform.auditService "Emits graph lifecycle audit events"
        platform.approvalService -> platform.auditService "Emits approval audit events"
        platform.transformationValidationService -> platform.auditService "Emits transformation validation audit events"
        platform.modelExecutionPolicyService -> platform.auditService "Emits runtime eligibility audit events"

        platform.orchestrationService -> platform.observabilityService "Emits execution telemetry and traces"
        platform.workflowService -> platform.observabilityService "Emits workflow telemetry and metrics"
        platform.modelExecutionPolicyService -> platform.observabilityService "Emits runtime policy telemetry and metrics"

        platform.orchestrationService -> platform.localRuntime "Invokes eligible model runtime"
        platform.orchestrationService -> platform.privateRuntime "Invokes eligible model runtime"
        platform.orchestrationService -> platform.externalRuntime "Invokes eligible model runtime"

        platform.evaluationService -> platform.localRuntime "Evaluates and qualifies"
        platform.evaluationService -> platform.privateRuntime "Evaluates and qualifies"
        platform.evaluationService -> platform.externalRuntime "Evaluates and qualifies"

        platform.contextService -> enterpriseIam "Resolves authoritative identity and entitlement context"
        platform.dataAccessService -> operationalSystems "Accesses approved operational enterprise data"
        platform.researchAgent -> researchSources "Queries approved external research sources"
        platform.externalRuntime -> externalModelProviders "Invokes approved external model providers"
        platform.workflowService -> operationalSystems "Executes approved enterprise actions"

        platform.orchestrationService -> platform.dataClassificationService "Requests execution-context classification"

        platform.orchestrationService -> platform.disclosureTransformationPolicyService "Provides capability and intended processing requirements"
        platform.dataClassificationService -> platform.disclosureTransformationPolicyService "Provides classified execution context"

        platform.disclosureTransformationPolicyService -> platform.dataTransformationService "Defines required disclosure transformation"
        platform.dataTransformationService -> platform.transformationValidationService "Provides transformed execution payload"

        platform.transformationValidationService -> platform.modelExecutionPolicyService "Provides validated transformation result and residual disclosure risk"
        platform.transformationValidationService -> platform.orchestrationService "Returns validated transformed execution payload"
        platform.evaluationService -> platform.modelExecutionPolicyService "Provides runtime capability qualification"

        platform.modelExecutionPolicyService -> platform.orchestrationService "Returns eligible runtime set"
        platform.policyService -> platform.modelExecutionPolicyService "Provides applicable execution and governance constraints"
    }

    views {

        systemContext platform "SystemContext" {
            include user
            include enterpriseApplications
            include platform
            include enterpriseIam
            include operationalSystems
            include researchSources
            include externalModelProviders

            autoLayout lr
        }

        container platform "ArchitectureOverview" {
            include user

            include platform.experienceGateway

            include platform.orchestrationService

            include platform.domainAgent
            include platform.analysisAgent
            include platform.researchAgent

            include platform.retrievalService
            include platform.dataAccessService

            include platform.curationService
            include platform.promotionService

            include platform.canonicalStore
            include platform.semanticIndex
            include platform.knowledgeGraph

            include platform.localRuntime
            include platform.privateRuntime
            include platform.externalRuntime

            autoLayout tb
        }

        container platform "OrchestrationAgentPlane" {
            include user
            include enterpriseApplications

            include platform.experienceGateway

            include platform.orchestrationService
            include platform.policyService
            include platform.contextService
            include platform.taskState

            include platform.domainAgent
            include platform.analysisAgent
            include platform.researchAgent

            include platform.retrievalService
            include platform.graphService
            include platform.dataAccessService
            include platform.artifactEvidenceService
            include platform.workflowService
            include platform.approvalService

            include enterpriseIam
            include operationalSystems
            include researchSources

            autoLayout tb
        }

        container platform "EnterpriseDataKnowledgePlane" {
            include platform.retrievalService
            include platform.graphService
            include platform.dataAccessService
            include platform.artifactEvidenceService

            include platform.curationService
            include platform.promotionService
            include platform.indexMaintenanceService
            include platform.graphLifecycleService

            include platform.candidateStore
            include platform.canonicalStore
            include platform.semanticIndex
            include platform.knowledgeGraph
            include platform.artifactStore

            include operationalSystems

            autoLayout tb
        }

        dynamic platform "KnowledgeLifecycle" {
            platform.researchAgent -> platform.artifactEvidenceService "1. Produces finding and evidence"
            platform.artifactEvidenceService -> platform.curationService "2. Supplies eligible findings and evidence"
            platform.curationService -> platform.candidateStore "3. Creates governed knowledge candidate"
            platform.candidateStore -> platform.promotionService "4. Submits candidate for validation and review"
            platform.promotionService -> platform.canonicalStore "5. Promotes approved knowledge"
            platform.promotionService -> platform.indexMaintenanceService "6. Triggers index maintenance"
            platform.indexMaintenanceService -> platform.canonicalStore "7. Reads approved canonical knowledge"
            platform.indexMaintenanceService -> platform.semanticIndex "8. Maintains derived semantic index"
            platform.promotionService -> platform.graphLifecycleService "9. Submits approved relationship changes"
            platform.graphLifecycleService -> platform.knowledgeGraph "10. Maintains governed canonical relationships"

            autoLayout lr
        }

        dynamic platform "ModelExecutionTrustPolicy" {
            platform.orchestrationService -> platform.dataClassificationService "1. Requests execution-context classification"
            platform.dataClassificationService -> platform.disclosureTransformationPolicyService "2. Provides classified execution context"
            platform.orchestrationService -> platform.disclosureTransformationPolicyService "3. Provides capability and intended processing requirements"
            platform.disclosureTransformationPolicyService -> platform.dataTransformationService "4. Defines required disclosure transformation"
            platform.dataTransformationService -> platform.transformationValidationService "5. Produces transformed execution payload"

            platform.transformationValidationService -> platform.modelExecutionPolicyService "6. Provides validated transformation result and residual disclosure risk"
            platform.transformationValidationService -> platform.orchestrationService "7. Returns validated transformed execution payload"

            platform.policyService -> platform.modelExecutionPolicyService "8. Provides applicable execution and governance constraints"
            platform.evaluationService -> platform.modelExecutionPolicyService "9. Provides runtime capability qualification"

            platform.modelExecutionPolicyService -> platform.orchestrationService "10. Returns eligible runtime set"

            platform.orchestrationService -> platform.localRuntime "11. Invokes selected eligible runtime"
            platform.orchestrationService -> platform.privateRuntime "11. Invokes selected eligible runtime"
            platform.orchestrationService -> platform.externalRuntime "11. Invokes selected eligible runtime"

            autoLayout lr
        }

        styles {

            element "Element" {
                shape roundedbox
                strokeWidth 3
            }

            element "Person" {
                shape person
            }

            element "Database" {
                shape cylinder
            }

            element "Experience" {
                background #e3f2fd
                color #0d47a1
                stroke #1565c0
            }

            element "Orchestration" {
                background #ede7f6
                color #311b92
                stroke #5e35b1
            }

            element "Agent" {
                background #fff3e0
                color #e65100
                stroke #ef6c00
            }

            element "Service" {
                background #e8f5e9
                color #1b5e20
                stroke #388e3c
            }

            element "Governance" {
                background #fce4ec
                color #880e4f
                stroke #c2185b
            }

            element "State" {
                background #eceff1
                color #263238
                stroke #546e7a
            }

            element "Candidate" {
                background #fff8e1
                color #8d6e00
                stroke #f9a825
            }

            element "Canonical" {
                background #e8eaf6
                color #1a237e
                stroke #3949ab
            }

            element "Derived" {
                background #eceff1
                color #263238
                stroke #546e7a
            }

            element "Artifact" {
                background #f5f5f5
                color #212121
                stroke #616161
            }

            element "Runtime" {
                background #e0f2f1
                color #004d40
                stroke #00897b
            }

            element "Boundary" {
                strokeWidth 3
            }

            element "Graph" {
                background #e8eaf6
                color #1a237e
                stroke #5c6bc0
            }

            relationship "Relationship" {
                thickness 2
            }
        }
    }

    configuration {
        scope softwaresystem
    }
}