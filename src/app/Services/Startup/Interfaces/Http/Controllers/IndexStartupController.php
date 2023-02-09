<?php

namespace App\Services\Startup\Interfaces\Http\Controllers;

use Micromus\ServiceSwagger\Attributes\Responses\ResourceResponse;
use OpenApi\Attributes\Tag;
use OpenApi\Attributes\Get;
use App\Http\Controllers\AbstractController;
use Illuminate\Http\Resources\Json\JsonResource;
use App\Services\Startup\Interfaces\Http\Resources\MessageStartupResource;
use App\Services\Startup\Infrastructure\Contracts\GetStartupMessageInterface;

#[Tag(
    name: 'Startup',
    description: 'Методы сервиса Startup'
)]
final class IndexStartupController extends AbstractController
{
    #[Get(
        path: '/',
        summary: 'Получение приветственного сообщения',
        tags: ['Startup'],

        responses: [
            new ResourceResponse(MessageStartupResource::class)
        ]
    )]
    public function index(GetStartupMessageInterface $subservice): JsonResource
    {
        return new MessageStartupResource($subservice->getStartupMessage());
    }
}
