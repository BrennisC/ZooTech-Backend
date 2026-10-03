using Microsoft.AspNetCore.Mvc;
using ZooTech.Application.Common.Behaviors;
using ZooTech.Application.Common.Models;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.Common;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.CreateOrdenio;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.DeleteOrdenio;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.GenerateOrdeniosExcel;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.GenerateOrdeniosPdf;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.GetOrdenioById;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.ListOrdenios;
using ZooTech.Application.Modules.Module_ProduccionLeche.UseCases.Ordenios.UpdateOrdenio;
using ZooTech.Application.Modules.Module_Vacuno.UseCases.ListarVacunos;
using ZooTech.Domain.Ganaderia.Module_Vacuno.Entities.ListarVacuno;
using ZooTech.InterfaceAdapters.Modules.Module_ProduccionLeche.Controllers;
using ZooTech.InterfaceAdapters.Modules.Module_ProduccionLeche.DTOs.Requests;
using ZooTech.InterfaceAdapters.Modules.Module_ProduccionLeche.DTOs.Responses;

namespace ZooTech.InterfaceAdapters.UnitTests.Modules.Module_ProduccionLeche.Controllers;

public class ProduccionLecheControllerTests
{
    [Fact]
    public void Health_ReturnsOkResponse()
    {
        var dispatcher = new TestBehaviorDispatcher();
        var controller = CreateController(dispatcher);

        var result = controller.Health();

        var okResult = Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(okResult.Value);
    }

    [Fact]
    public async Task List_WhenPagingIsNull_UsesDefaultPagingAndReturnsOk()
    {
        var dispatcher = new TestBehaviorDispatcher();
        ListOrdeniosQuery? capturedQuery = null;

        dispatcher.Setup<ListOrdeniosQuery, ListOrdeniosOutput>((query, _) =>
        {
            capturedQuery = query;

            return Task.FromResult(
                new ListOrdeniosOutput(
                    new[] { CreateOrdenioListOutput() },
                    TotalCount: 1));
        });

        var controller = CreateController(dispatcher);

        var result = await controller.List(
            vacunoId: 10,
            estadoOrdenioCode: "ACTIVO",
            fechaDesde: null,
            fechaHasta: null,
            page: null,
            pageSize: null,
            CancellationToken.None);

        var okResult = Assert.IsType<OkObjectResult>(result);
        var response =
            AssertGeneralResponseData<ListOrdeniosResponse>(okResult.Value);

        Assert.Equal(10, capturedQuery?.VacunoId);
        Assert.Equal("ACTIVO", capturedQuery?.EstadoOrdenioCode);
        Assert.Equal(1, capturedQuery?.Page);
        Assert.Equal(20, capturedQuery?.PageSize);

        Assert.Single(response.Data);
        Assert.Equal(1, response.Pagination.Page);
        Assert.Equal(20, response.Pagination.Limit);
    }

    [Fact]
    public async Task Create_MapsRequestToCommandAndReturnsCreated()
    {
        var dispatcher = new TestBehaviorDispatcher();
        CreateOrdenioCommand? capturedCommand = null;

        dispatcher.Setup<CreateOrdenioCommand, CreateOrdenioOutput>((command, _) =>
        {
            capturedCommand = command;

            return Task.FromResult(
                new CreateOrdenioOutput(CreateOrdenioOutput()));
        });

        var controller = CreateController(dispatcher);

        var request = new CreateOrdenioRequest(
            "ORD-001",
            new DateTime(2026, 7, 7, 10, 0, 0),
            10,
            20,
            12.5m,
            "ACTIVO",
            "Sin observaciones");

        var result = await controller.Create(
            request,
            CancellationToken.None);

        var createdResult = Assert.IsType<CreatedResult>(result);

        var response =
            AssertGeneralResponseData<OrdenioResponse>(createdResult.Value);

        Assert.Equal(
            "/api/v1/produccion-leche/1",
            createdResult.Location);

        Assert.Equal(request.Codigo, capturedCommand?.Codigo);
        Assert.Equal(request.FechaHora, capturedCommand?.FechaHora);
        Assert.Equal(request.VacunoId, capturedCommand?.VacunoId);
        Assert.Equal(
            request.EncargadoUsuarioId,
            capturedCommand?.EncargadoUsuarioId);
        Assert.Equal(request.Litros, capturedCommand?.Litros);
        Assert.Equal(
            request.EstadoOrdenioCode,
            capturedCommand?.EstadoOrdenioCode);
        Assert.Equal(
            request.Observaciones,
            capturedCommand?.Observaciones);

        Assert.Equal(1, response.Id);
    }

    [Fact]
    public async Task GenerateExcel_MapsComparativoQueryAndReturnsFile()
    {
        var dispatcher = new TestBehaviorDispatcher();
        GenerateOrdeniosComparationExcelQuery? capturedQuery = null;

        dispatcher.Setup<
            GenerateOrdeniosComparationExcelQuery,
            GenerateOrdeniosExcelOutput>((query, _) =>
        {
            capturedQuery = query;

            return Task.FromResult(
                new GenerateOrdeniosExcelOutput(
                    new byte[] { 1 },
                    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "ordenios.xlsx"));
        });

        var controller = CreateController(dispatcher);

        var fechaDesde = new DateTime(2026, 7, 1, 8, 0, 0);
        var fechaHasta = new DateTime(2026, 7, 2, 8, 0, 0);

        var result = await controller.GenerateExcel(
            vacunoId: 10,
            estadoOrdenioCode: "ACTIVO",
            fechaDesde: fechaDesde,
            fechaHasta: fechaHasta,
            comparativo: true,
            CancellationToken.None);

        var fileResult = Assert.IsType<FileContentResult>(result);

        Assert.Equal(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            fileResult.ContentType);

        Assert.Equal(
            "ordenios.xlsx",
            fileResult.FileDownloadName);

        Assert.Equal(10, capturedQuery?.VacunoId);
        Assert.Equal(
            "ACTIVO",
            capturedQuery?.EstadoOrdenioCode);
        Assert.Equal(
            fechaDesde,
            capturedQuery?.FechaDesde);
        Assert.Equal(
            fechaHasta,
            capturedQuery?.FechaHasta);
        Assert.True(capturedQuery?.Comparativo);
    }

    private static ProduccionLecheController CreateController(
        TestBehaviorDispatcher dispatcher)
        => new(dispatcher);

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

    private static T AssertGeneralResponseData<T>(object? value)
    {
        Assert.NotNull(value);
        var success = value.GetType().GetProperty("Success")?.GetValue(value);
        var data = value.GetType().GetProperty("Data")?.GetValue(value);

        Assert.Equal(true, success);
        return Assert.IsType<T>(data);
    }

    private static OrdenioOutput CreateOrdenioOutput()
    {
        var now = new DateTime(2026, 7, 7, 10, 0, 0);

        return new OrdenioOutput(
            1,
            "ORD-001",
            now,
            10,
            "Luna",
            20,
            "Juan Perez",
            12.5m,
            "ACTIVO",
            "Sin observaciones",
            now,
            now);
    }

    private static OrdenioListOutput CreateOrdenioListOutput()
    {
        var now = new DateTime(2026, 7, 7, 10, 0, 0);

        return new OrdenioListOutput(
            1,
            "ORD-001",
            now,
            10,
            "Luna",
            "VAC-001",
            20,
            "Juan Perez",
            12.5m,
            "ACTIVO",
            "Sin observaciones",
            now,
            now);
    }
}
