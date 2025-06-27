using System.Diagnostics.Metrics;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;

var builder = WebApplication.CreateBuilder(args);

var serviceName = "dotnet-otel-collector-demo";
var serviceVersion = "1.0.0";

var meter = new Meter("MyAppMeter", serviceVersion);
var counter = meter.CreateCounter<long>("my_custom_counter");

builder.Services.AddOpenTelemetry()
    .WithMetrics(metrics =>
    {
        metrics
            .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService(serviceName))
            .AddMeter("MyAppMeter")
            .AddAspNetCoreInstrumentation()
            .AddHttpClientInstrumentation()
            .AddOtlpExporter(o =>
            {
                o.Endpoint = new Uri("http://otel-collector-opentelemetry-collector.monitoring.svc.cluster.local:4317");
            });
    });

var app = builder.Build();

app.MapGet("/", () => "Burası benim ana sayfam.");

app.MapGet("/count", () =>
{
    counter.Add(1, new KeyValuePair<string, object?>("endpoint", "/count"));
    return Results.Ok("Metric gönderildi.");
});

app.Run();
