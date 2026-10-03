using System.Net;
using System.Net.Http.Json;
using FluentAssertions;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using ZooTech.Application.Common.Behaviors;
using ZooTech.Application.Common.Gateway.Auditing;
using ZooTech.Application.Common.Gateway.Context;
using ZooTech.Application.Common.Gateway.Tenant;
using ZooTech.Application.Common.Models;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.Common;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.CreateTriaje;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.DeleteTriaje;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GenerateTriajesExcel;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GenerateTriajesPdf;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetAllTipoPesos;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetAllTriajes;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetAllVacunosSanidad;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetHistorialByVacunoId;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetHistorialGeneral;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.GetTriajeById;
using ZooTech.Application.Modules.Module_Sanidad.UseCases.UpdateTriaje;
using ZooTech.Domain.Admin.Enums;
using ZooTech.Domain.Shared.Enums;
using ZooTech.Infrastructure.Context;
using ZooTech.InterfaceAdapters.DTOs;
using ZooTech.InterfaceAdapters.Modules.Module_Sanidad.DTOs.Requests;
using ZooTech.InterfaceAdapters.Modules.Module_Sanidad.DTOs.Responses;

namespace ZooTech.API.IntegrationTests.Controllers.Sanidad;

public class TriajeApiIntegrationTests
{
    private static readonly DateTime Now = new(2026, 7, 22, 10, 0, 0);
    private readonly HttpClient _client;
    private readonly SanidadApiTestState _state;

    public TriajeApiIntegrationTests()
    {
        _state = new SanidadApiTestState();
        var factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.ConfigureAppConfiguration((_, config) =>
                {
                    config.AddInMemoryCollection(new Dictionary<string, string?>
                    {
                        ["MultiTenant:BaseDomain"] = "zootech.test",
                        ["MultiTenant:AdminSubDomain"] = "admin",
                        ["ConnectionStrings:TenantCatalogConnection"] = "Server=(localdb)\\mssqllocaldb;Database=ZooTechApiTests;Trusted_Connection=True;",
                        ["Jwt:Issuer"] = "ZooTech.Tests",
                        ["Jwt:Audience"] = "ZooTech.Tests",
                        ["Jwt:SecretKey"] = "01234567890123456789012345678901",
                        ["MongoDb:ConnectionString"] = "mongodb://localhost:27017",
                    });
                });

                builder.ConfigureTestServices(services =>
                {
                    // ============================================================
                    // Infraestructura que no queremos ejecutar realmente
                    // ============================================================

                    services.RemoveAll<IAppAuditService>();
                    services.AddSingleton<IAppAuditService, NoopAuditService>();

                    services.RemoveAll<ITenantStore>();
                    services.AddSingleton<ITenantStore, FakeTenantStore>();

                    services.RemoveAll<ITenantContext>();
                    services.AddScoped<ITenantContext, TenantContext>();


                    // ============================================================
                    // Estado compartido de los tests
                    // ============================================================

                    services.AddSingleton(_state);


                    // ============================================================
                    // BehaviorDispatcher falso
                    //
                    // Los controllers seguirán usando IBehaviorDispatcher,
                    // pero durante el test no ejecutaremos los handlers reales.
                    // ============================================================

                    services.RemoveAll<IBehaviorDispatcher>();

                    var dispatcher = new TestBehaviorDispatcher();


                    // ============================================================
                    // GET ALL TRIAJES
                    // ============================================================

                    dispatcher.Setup<GetAllTriajesQuery, GetAllTriajesOutput>(
                        (query, _) =>
                        {
                            _state.GetAllQuery = query;

                            return Task.FromResult(
                                new GetAllTriajesOutput(
                                    new[]
                                    {
                                        CreateTriajeOutput()
                                    },
                                    1
                                )
                            );
                        });


                    // ============================================================
                    // GET TRIAJE BY ID
                    // ============================================================

                    dispatcher.Setup<GetTriajeByIdQuery, GetTriajeByIdOutput>(
                        (query, _) =>
                        {
                            _state.GetByIdCommand = query;

                            return Task.FromResult(
                                new GetTriajeByIdOutput(
                                    query.Id,
                                    $"TRI{query.Id:000}",
                                    Now,
                                    5,
                                    "Luna",
                                    "CONTROL",
                                    120m,
                                    "Obs",
                                    "ACTIVO",
                                    10,
                                    Now
                                )
                            );
                        });


                    // ============================================================
                    // CREATE TRIAJE
                    // ============================================================

                    dispatcher.Setup<CreateTriajeCommand, CreateTriajeOutput>(
                        (command, _) =>
                        {
                            _state.CreateCommand = command;

                            return Task.FromResult(
                                new CreateTriajeOutput(
                                    10,
                                    "TRI010",
                                    Now,
                                    command.VacunoId,
                                    command.TipoPesoCode!,
                                    command.PesoKg,
                                    command.Observaciones,
                                    "ACTIVO",
                                    command.EncargadoUsuarioId,
                                    Now
                                )
                            );
                        });


                    // ============================================================
                    // UPDATE TRIAJE
                    // ============================================================

                    dispatcher.Setup<UpdateTriajeCommand, UpdateTriajeOutput>(
                        (command, _) =>
                        {
                            _state.UpdateCommand = command;

                            return Task.FromResult(
                                new UpdateTriajeOutput(
                                    command.Id,
                                    $"TRI{command.Id:000}",
                                    Now,
                                    5,
                                    "Luna",
                                    command.TipoPesoCode!,
                                    command.PesoKg,
                                    command.Observaciones,
                                    "ACTIVO",
                                    command.EncargadoUsuarioId,
                                    Now,
                                    Now
                                )
                            );
                        });


                    // ============================================================
                    // DELETE TRIAJE
                    // ============================================================

                    dispatcher.Setup<DeleteTriajeCommand, EmptyOutput>(
                        (command, _) =>
                        {
                            _state.DeleteCommand = command;

                            return Task.FromResult(
                                EmptyOutput.Value
                            );
                        });


                    // ============================================================
                    // CATÁLOGO: TIPOS DE PESO
                    // ============================================================

                    dispatcher.Setup<EmptyCommandQuery, GetAllTipoPesosOutput>(
                        (_, _) =>
                        {
                            return Task.FromResult(
                                new GetAllTipoPesosOutput(
                                    new[]
                                    {
                                        new TipoPesoItemOutput(
                                            "CONTROL",
                                            "Peso Control"
                                        )
                                    }
                                )
                            );
                        });


                    // ============================================================
                    // CATÁLOGO: VACUNOS
                    // ============================================================

                    dispatcher.Setup<EmptyCommandQuery, GetAllVacunosSanidadOutput>(
                        (_, _) =>
                        {
                            return Task.FromResult(
                                new GetAllVacunosSanidadOutput(
                                    new[]
                                    {
                                        new VacunoSanidadItemOutput(
                                            5,
                                            "VAC005",
                                            "Luna"
                                        )
                                    }
                                )
                            );
                        });


                    // ============================================================
                    // HISTORIAL POR VACUNO
                    // ============================================================

                    dispatcher.Setup<GetHistorialByVacunoIdQuery, GetHistorialByVacunoIdOutput>(
                        (query, _) =>
                        {
                            _state.HistorialCommand = query;

                            return Task.FromResult(
                                new GetHistorialByVacunoIdOutput(
                                    new[]
                                    {
                                        new HistorialTriajeItemOutput(
                                            1,
                                            Now,
                                            "CONTROL",
                                            120m
                                        )
                                    }
                                )
                            );
                        });


                    // ============================================================
                    // HISTORIAL GENERAL
                    // ============================================================

                    dispatcher.Setup<GetHistorialGeneralQuery, GetHistorialGeneralOutput>(
                        (query, _) =>
                        {
                            _state.HistorialGeneralCommand = query;

                            return Task.FromResult(
                                new GetHistorialGeneralOutput(
                                    new[]
                                    {
                                        new HistorialTriajeItemOutput(
                                            1,
                                            Now,
                                            "CONTROL",
                                            120m
                                        )
                                    }
                                )
                            );
                        });


                    // ============================================================
                    // GENERAR PDF
                    // ============================================================

                    dispatcher.Setup<GenerateTriajesPdfQuery, GenerateTriajesPdfOutput>(
                        (query, _) =>
                        {
                            _state.PdfQuery = query;

                            return Task.FromResult(
                                new GenerateTriajesPdfOutput(
                                    new byte[] { 1, 2, 3 },
                                    "application/pdf",
                                    "triajes.pdf"
                                )
                            );
                        });


                    // ============================================================
                    // GENERAR EXCEL
                    // ============================================================

                    dispatcher.Setup<GenerateTriajesExcelQuery, GenerateTriajesExcelOutput>(
                        (query, _) =>
                        {
                            _state.ExcelQuery = query;

                            return Task.FromResult(
                                new GenerateTriajesExcelOutput(
                                    new byte[] { 1, 2, 3 },
                                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                    "triajes.xlsx"
                                )
                            );
                        });


                    // ============================================================
                    // Registrar el dispatcher falso
                    // ============================================================

                    services.AddSingleton<IBehaviorDispatcher>(dispatcher);
                });
                            });

        _client = factory.CreateClient();
        _client.DefaultRequestHeaders.Add("X-Tenant-Url", "test.zootech.test");
    }

    [Fact]
    public async Task GetAll_MapsQueryParamsAndReturnsPagedResponse()
    {
        var response = await _client.GetAsync("/api/v1/triaje?pagina=2&tamano=5&fecha=2026-07-22&fechaDesde=2026-07-01&fechaHasta=2026-07-31&codigo=TRI&nombre=Luna&tipoPeso=CONTROL&pesoKg=120&vacunoId=5&uniqueVacuno=true");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadFromJsonAsync<GeneralResponseDTO<PagedTriajeResponse>>();
        body.Should().NotBeNull();
        body!.Success.Should().BeTrue();
        body.Data!.Data.Should().ContainSingle();
        body.Data.Pagination.Page.Should().Be(2);
        body.Data.Pagination.Limit.Should().Be(5);
        _state.GetAllQuery.Should().NotBeNull();
        _state.GetAllQuery!.Codigo.Should().Be("TRI");
        _state.GetAllQuery.Nombre.Should().Be("Luna");
        _state.GetAllQuery.UniqueVacuno.Should().BeTrue();
    }

    [Fact]
    public async Task GetById_ReturnsTriajeResponse()
    {
        var response = await _client.GetAsync("/api/v1/triaje/9");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var body = await response.Content.ReadFromJsonAsync<GeneralResponseDTO<TriajeResponse>>();
        body!.Data!.Id.Should().Be(9);
        _state.GetByIdCommand!.Id.Should().Be(9);
    }

    [Fact]
    public async Task Create_MapsBodyAndReturnsCreated()
    {
        var request = new TriajeRequest(5, "CONTROL", 120m, "Obs", 10, Now.AddDays(-1));

        var response = await _client.PostAsJsonAsync("/api/v1/triaje", request);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        var body = await response.Content.ReadFromJsonAsync<GeneralResponseDTO<TriajeResponse>>();
        body!.Data!.Id.Should().Be(10);
        response.Headers.Location?.OriginalString.Should().Contain("/10");
        _state.CreateCommand!.VacunoId.Should().Be(5);
        _state.CreateCommand.TipoPesoCode.Should().Be("CONTROL");
    }

    [Fact]
    public async Task Update_MapsRouteAndBodyAndReturnsOk()
    {
        var request = new UpdateTriajeRequest("FINAL", 130m, "Actualizado", 11);

        var response = await _client.PatchAsJsonAsync("/api/v1/triaje/12", request);

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        _state.UpdateCommand!.Id.Should().Be(12);
        _state.UpdateCommand.TipoPesoCode.Should().Be("FINAL");
    }

    [Fact]
    public async Task Delete_MapsRouteAndBodyAndReturnsNoContent()
    {
        var response = await _client.SendAsync(new HttpRequestMessage(HttpMethod.Delete, "/api/v1/triaje/13")
        {
            Content = JsonContent.Create(new DeleteTriajeRequest("Duplicado")),
        });

        response.StatusCode.Should().Be(HttpStatusCode.NoContent);
        _state.DeleteCommand!.Id.Should().Be(13);
        _state.DeleteCommand.MotivoEliminacion.Should().Be("Duplicado");
    }

    [Fact]
    public async Task GeneratePdf_ReturnsPdfFile()
    {
        var response = await _client.GetAsync("/api/v1/triaje/reporte/pdf?fechaDesde=2026-07-01&fechaHasta=2026-07-31&codigo=TRI");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        response.Content.Headers.ContentType!.MediaType.Should().Be("application/pdf");
        _state.PdfQuery!.FechaDesde.Should().Be("2026-07-01");
        _state.PdfQuery.Codigo.Should().Be("TRI");
    }

    [Fact]
    public async Task GenerateExcel_ReturnsExcelFile()
    {
        var response = await _client.GetAsync("/api/v1/triaje/reporte/excel?fechaDesde=2026-07-01&fechaHasta=2026-07-31&nombre=Luna");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        response.Content.Headers.ContentType!.MediaType.Should().Be("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        _state.ExcelQuery!.Nombre.Should().Be("Luna");
    }

    [Fact]
    public async Task CatalogAndHistorialEndpoints_ReturnOk()
    {
        (await _client.GetAsync("/api/v1/triaje/tipos-peso")).StatusCode.Should().Be(HttpStatusCode.OK);
        (await _client.GetAsync("/api/v1/triaje/vacunos")).StatusCode.Should().Be(HttpStatusCode.OK);

        var historial = await _client.GetAsync("/api/v1/triaje/historial/5?desde=2026-07-01&hasta=2026-07-31");
        historial.StatusCode.Should().Be(HttpStatusCode.OK);
        _state.HistorialCommand!.Vacunoid.Should().Be(5);

        var general = await _client.GetAsync("/api/v1/triaje/historial-general?desde=2026-07-01&hasta=2026-07-31");
        general.StatusCode.Should().Be(HttpStatusCode.OK);
        _state.HistorialGeneralCommand!.FechaHasta.Should().Be("2026-07-31");
    }

    private static BehaviorPipeline<TRequest, TResponse> Pipeline<TRequest, TResponse>(Func<TRequest, Task<TResponse>> handler)
        => new(Array.Empty<IBehavior<TRequest, TResponse>>(), (request, _) => handler(request));

    private static TriajeOutput CreateTriajeOutput(long id = 1)
        => new(id, $"TRI{id:000}", Now, 5, "Luna", "CONTROL", 120m, "Obs", "ACTIVO", 10, Now);

    private sealed class SanidadApiTestState
    {
        public GetAllTriajesQuery? GetAllQuery { get; set; }
        public GetTriajeByIdQuery? GetByIdCommand { get; set; }
        public CreateTriajeCommand? CreateCommand { get; set; }
        public UpdateTriajeCommand? UpdateCommand { get; set; }
        public DeleteTriajeCommand? DeleteCommand { get; set; }
        public GenerateTriajesPdfQuery? PdfQuery { get; set; }
        public GenerateTriajesExcelQuery? ExcelQuery { get; set; }
        public GetHistorialByVacunoIdQuery? HistorialCommand { get; set; }
        public GetHistorialGeneralQuery? HistorialGeneralCommand { get; set; }
    }

    private sealed class TestBehaviorDispatcher : IBehaviorDispatcher
    {
        private readonly Dictionary<Type, Func<object, CancellationToken, Task<object>>>
            _handlers = new();

        public void Setup<TRequest, TResponse>(
            Func<TRequest, CancellationToken, Task<TResponse>> handler)
        {
            _handlers[typeof(TRequest)] = async (request, cancellationToken) =>
                await handler((TRequest)request, cancellationToken);
        }

        public async Task<TResponse> Send<TRequest, TResponse>(
            TRequest request,
            CancellationToken cancellationToken = default)
        {
            if (!_handlers.TryGetValue(
                    typeof(TRequest),
                    out var handler))
            {
                throw new InvalidOperationException(
                    $"No test handler configured for {typeof(TRequest).Name}");
            }

            var response = await handler(request, cancellationToken);

            return (TResponse)response;
        }
    }

    private sealed class FakeTenantStore : ITenantStore
    {
        public Task<TenantInfo?> GetBySubDomainAsync(string subDomain)
            => Task.FromResult<TenantInfo?>(new TenantInfo
            {
                Id = 1,
                SubDomain = subDomain,
                Code = "TEST",
                LegalName = "Test Tenant SAC",
                DisplayName = "Test Tenant",
                DatabaseName = "ZooTech_Test_Db",
                IsDatabaseActive = true,
                Status = TenantStatus.ACTIVE,
                Email = "test@zootech.test",
            });
    }

    private sealed class NoopAuditService : IAppAuditService
    {
        public Task AuditEventAsync(AuditEventInfo auditEventInfo) => Task.CompletedTask;

        public Task AuditErrorAsync(AuditErrorInfo auditErrorInfo) => Task.CompletedTask;
    }
}
