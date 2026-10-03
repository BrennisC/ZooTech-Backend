using Microsoft.AspNetCore.Mvc;

using ZooTech.Application.Common.Behaviors;
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

using ZooTech.InterfaceAdapters.DTOs;
using ZooTech.InterfaceAdapters.Module_Sanidad.Controllers;
using ZooTech.InterfaceAdapters.Modules.Module_Sanidad.DTOs.Requests;
using ZooTech.InterfaceAdapters.Modules.Module_Sanidad.DTOs.Responses;

namespace ZooTech.InterfaceAdapters.UnitTests.Modules.Module_Sanidad.Controllers;

public class TriajeControllerTests
{
    private static readonly DateTime Now = new(2026, 7, 22, 10, 0, 0);

    [Fact]
    public async Task GetAll_MapsQueryParamsAndReturnsOk()
    {
        GetAllTriajesQuery? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<GetAllTriajesQuery, GetAllTriajesOutput>((query, _) =>
        {
            captured = query;

            return Task.FromResult(
                new GetAllTriajesOutput(
                    new[] { CreateTriajeOutput() },
                    1));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.GetAll(
            0,
            200,
            "2026-07-22",
            "2026-07-01",
            "2026-07-31",
            "TRI",
            "Luna",
            "CONTROL",
            "120",
            5,
            true);

        var okResult = Assert.IsType<OkObjectResult>(result);
        var response =
            AssertGeneralResponseData<PagedTriajeResponse>(okResult.Value);

        Assert.NotNull(captured);
        Assert.Equal(0, captured.Pagina);
        Assert.Equal(200, captured.Tamano);
        Assert.Equal("2026-07-22", captured.Fecha);
        Assert.Equal("2026-07-01", captured.FechaDesde);
        Assert.Equal("2026-07-31", captured.FechaHasta);
        Assert.Equal("TRI", captured.Codigo);
        Assert.Equal("Luna", captured.Nombre);
        Assert.Equal("CONTROL", captured.TipoPeso);
        Assert.Equal("120", captured.PesoKg);
        Assert.Equal(5, captured.VacunoId);
        Assert.True(captured.UniqueVacuno);
        Assert.Equal(1, response.Pagination.Page);
        Assert.Equal(100, response.Pagination.Limit);
    }

    [Fact]
    public async Task Create_MapsRequestAndReturnsCreatedAtAction()
    {
        CreateTriajeCommand? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<CreateTriajeCommand, CreateTriajeOutput>((command, _) =>
        {
            captured = command;

            return Task.FromResult(
                new CreateTriajeOutput(
                    9,
                    "TRI009",
                    Now,
                    command.VacunoId,
                    command.TipoPesoCode!,
                    command.PesoKg,
                    command.Observaciones,
                    "ACTIVO",
                    command.EncargadoUsuarioId,
                    Now));
        });

        var controller = CreateController(dispatcher);

        var request = new TriajeRequest(
            5,
            "CONTROL",
            120m,
            "Obs",
            10,
            Now.AddDays(-1));

        var result = await controller.Create(request);

        var createdResult =
            Assert.IsType<CreatedAtActionResult>(result);

        var response =
            AssertGeneralResponseData<TriajeResponse>(
                createdResult.Value);

        Assert.Equal(
            nameof(TriajeController.GetById),
            createdResult.ActionName);

        Assert.Equal(
            9L,
            createdResult.RouteValues?["id"]);

        Assert.Equal(5, captured?.VacunoId);
        Assert.Equal("CONTROL", captured?.TipoPesoCode);
        Assert.Equal(120m, captured?.PesoKg);
        Assert.Equal("Obs", captured?.Observaciones);
        Assert.Equal(10, captured?.EncargadoUsuarioId);
        Assert.Equal(
            Now.AddDays(-1),
            captured?.FechaHora);

        Assert.Equal(9, response.Id);
    }

    [Fact]
    public async Task Delete_MapsRequestAndReturnsNoContent()
    {
        DeleteTriajeCommand? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<DeleteTriajeCommand, EmptyOutput>((command, _) =>
        {
            captured = command;

            return Task.FromResult(EmptyOutput.Value);
        });

        var controller = CreateController(dispatcher);

        var result = await controller.Delete(
            8,
            new DeleteTriajeRequest("Duplicado"));

        Assert.IsType<NoContentResult>(result);
        Assert.Equal(8, captured?.Id);
        Assert.Equal(
            "Duplicado",
            captured?.MotivoEliminacion);
    }

    [Fact]
    public async Task GeneratePdf_MapsFiltersAndReturnsFile()
    {
        GenerateTriajesPdfQuery? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            GenerateTriajesPdfQuery,
            GenerateTriajesPdfOutput>((query, _) =>
        {
            captured = query;

            return Task.FromResult(
                new GenerateTriajesPdfOutput(
                    new byte[] { 1 },
                    "application/pdf",
                    "triajes.pdf"));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.GeneratePdf(
            "2026-07-22",
            "2026-07-01",
            "2026-07-31",
            "TRI",
            "Luna",
            "CONTROL",
            "120",
            5,
            CancellationToken.None);

        var fileResult =
            Assert.IsType<FileContentResult>(result);

        Assert.Equal(
            "application/pdf",
            fileResult.ContentType);

        Assert.Equal(
            "triajes.pdf",
            fileResult.FileDownloadName);

        Assert.Equal("TRI", captured?.Codigo);
        Assert.Equal("Luna", captured?.Nombre);
        Assert.Equal(5, captured?.VacunoId);
    }

    [Fact]
    public async Task GenerateExcel_MapsFiltersAndReturnsFile()
    {
        GenerateTriajesExcelQuery? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            GenerateTriajesExcelQuery,
            GenerateTriajesExcelOutput>((query, _) =>
        {
            captured = query;

            return Task.FromResult(
                new GenerateTriajesExcelOutput(
                    new byte[] { 1 },
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "triajes.xlsx"));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.GenerateExcel(
            "2026-07-22",
            "2026-07-01",
            "2026-07-31",
            "TRI",
            "Luna",
            "CONTROL",
            "120",
            5,
            CancellationToken.None);

        var fileResult =
            Assert.IsType<FileContentResult>(result);

        Assert.Equal(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            fileResult.ContentType);

        Assert.Equal(
            "triajes.xlsx",
            fileResult.FileDownloadName);

        Assert.Equal(
            "CONTROL",
            captured?.TipoPeso);

        Assert.Equal(
            "120",
            captured?.PesoKg);
    }

    [Fact]
    public async Task GetHistorial_MapsVacunoIdDatesAndReturnsOk()
    {
        GetHistorialByVacunoIdQuery? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            GetHistorialByVacunoIdQuery,
            GetHistorialByVacunoIdOutput>((query, _) =>
        {
            captured = query;

            return Task.FromResult(
                new GetHistorialByVacunoIdOutput(
                    new[]
                    {
                        new HistorialTriajeItemOutput(
                            1,
                            Now,
                            "CONTROL",
                            120m)
                    }));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.GetHistorial(
            5,
            "2026-07-01",
            "2026-07-31");

        Assert.IsType<OkObjectResult>(result);

        Assert.Equal(5, captured?.Vacunoid);
        Assert.Equal(
            "2026-07-01",
            captured?.FechaDesde);

        Assert.Equal(
            "2026-07-31",
            captured?.FechaHasta);
    }

    [Fact]
    public async Task GetHistorialGeneral_MapsDatesAndReturnsOk()
    {
        GetHistorialGeneralQuery? captured = null;

        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            GetHistorialGeneralQuery,
            GetHistorialGeneralOutput>((query, _) =>
        {
            captured = query;

            return Task.FromResult(
                new GetHistorialGeneralOutput(
                    new[]
                    {
                        new HistorialTriajeItemOutput(
                            1,
                            Now,
                            "CONTROL",
                            120m)
                    }));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.GetHistorialGeneral(
            "2026-07-01",
            "2026-07-31");

        Assert.IsType<OkObjectResult>(result);

        Assert.Equal(
            "2026-07-01",
            captured?.FechaDesde);

        Assert.Equal(
            "2026-07-31",
            captured?.FechaHasta);
    }

    [Fact]
    public async Task GetTiposPeso_ReturnsOk()
    {
        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            EmptyCommandQuery,
            GetAllTipoPesosOutput>((_, _) =>
            Task.FromResult(
                new GetAllTipoPesosOutput(
                    new[]
                    {
                        new TipoPesoItemOutput(
                            "CONTROL",
                            "Peso Control")
                    })));

        var controller = CreateController(dispatcher);

        var result = await controller.GetTiposPeso();

        Assert.IsType<OkObjectResult>(result);
    }

    [Fact]
    public async Task GetVacunos_ReturnsOk()
    {
        var dispatcher = new TestBehaviorDispatcher();

        dispatcher.Setup<
            EmptyCommandQuery,
            GetAllVacunosSanidadOutput>((_, _) =>
            Task.FromResult(
                new GetAllVacunosSanidadOutput(
                    new[]
                    {
                        new VacunoSanidadItemOutput(
                            1,
                            "VAC001",
                            "Luna")
                    })));

        var controller = CreateController(dispatcher);

        var result = await controller.GetVacunos();

        Assert.IsType<OkObjectResult>(result);
    }

    private static TriajeController CreateController(
        TestBehaviorDispatcher dispatcher)
        => new(dispatcher);

    private static TriajeOutput CreateTriajeOutput()
        => new(
            1,
            "TRI001",
            Now,
            1,
            "Luna",
            "CONTROL",
            120m,
            null,
            "ACTIVO",
            10,
            Now);

    private static T AssertGeneralResponseData<T>(object? value)
    {
        var response =
            Assert.IsType<GeneralResponseDTO<T>>(value);

        Assert.True(response.Success);

        return Assert.IsType<T>(response.Data);
    }

    private sealed class TestBehaviorDispatcher : IBehaviorDispatcher
    {
        private readonly Dictionary<
            (Type Request, Type Response),
            Func<object, CancellationToken, Task<object>>> _handlers = new();

        public void Setup<TRequest, TResponse>(
            Func<TRequest, CancellationToken, Task<TResponse>> handler)
        {
            _handlers[(typeof(TRequest), typeof(TResponse))] =
                async (request, cancellationToken) =>
                    await handler(
                        (TRequest)request,
                        cancellationToken);
        }

        public async Task<TResponse> Send<TRequest, TResponse>(
            TRequest request,
            CancellationToken cancellationToken = default)
        {
            if (!_handlers.TryGetValue(
                    (typeof(TRequest), typeof(TResponse)),
                    out var handler))
            {
                throw new InvalidOperationException(
                    $"No test handler configured for " +
                    $"{typeof(TRequest).Name} -> " +
                    $"{typeof(TResponse).Name}");
            }

            var response = await handler(
                request!,
                cancellationToken);

            return (TResponse)response;
        }
    }
}